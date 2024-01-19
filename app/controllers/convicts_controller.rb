class ConvictsController < ApplicationController
  include InterRessortFlashes

  before_action :authenticate_user!

  def show
    @convict = policy_scope(Convict).find(params[:id])
    @history_items = HistoryItem.where(convict: @convict, category: %w[appointment convict])
                                .order(created_at: :desc)

    set_inter_ressort_flashes if current_user.can_use_inter_ressort?

    authorize @convict
  end

  def index
    query = params[:q]
    query = add_prefix_to_phone(params[:q]) if query =~ (/\d/) && !/^(\+33)/.match?(params[:q])

    @convicts = fetch_convicts(query)

    authorize @convicts
  end

  def new
    @convict = Convict.new
    authorize @convict

    @convict.appointments.build
  end

  def create
    @convict = Convict.new(convict_params)
    @convict.creating_organization = current_organization
    @convict.current_user = current_user
    @convict.update_organizations(current_user, autosave: false)
    authorize @convict

    if @convict.save
      # TODO : mettre une petite notif pour dire que le probationnaire a bien été créé ?
      redirect_to select_path(params)
    else
      @duplicate_convict = find_duplicate_convict

      divestment_decision

      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @convict = policy_scope(Convict).find(params[:id])
    set_inter_ressort_flashes if current_user.can_use_inter_ressort?

    authorize @convict
  end

  def update
    @convict = policy_scope(Convict).find(params[:id])
    authorize @convict

    old_phone = @convict.phone

    update_convict

    if @convict.errors.empty?
      handle_successful_update(old_phone)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @convict = policy_scope(Convict).find(params[:id])
    authorize @convict

    @convict.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to convicts_path, notice: 'Le probationnaire a bien été supprimé' }
    end
  end

  def archive
    @convict = policy_scope(Convict).find(params[:convict_id])
    authorize @convict

    @convict.discard
    HistoryItemFactory.perform(convict: @convict, event: 'archive_convict', category: 'convict')

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to convict_path(@convict), notice: 'Le probationnaire a bien été archivé' }
    end
  end

  def unarchive
    @convict = policy_scope(Convict).find(params[:convict_id])
    authorize @convict

    @convict.undiscard
    HistoryItemFactory.perform(convict: @convict, event: 'unarchive_convict', category: 'convict')

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to convict_path(@convict), notice: 'Le probationnaire a bien été désarchivé' }
    end
  end

  def self_assign
    @convict = policy_scope(Convict).find(params[:convict_id])
    authorize @convict
    @convict.update_attribute(:user, current_user)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to convicts_path, notice: t('.notice') }
    end
  end

  def unassign
    @convict = policy_scope(Convict).find(params[:convict_id])
    authorize @convict
    @convict.update_attribute(:user, nil)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to convicts_path, notice: t('.notice') }
    end
  end

  private

  def divestment_decision
    decision = DivestmentDecision.new(@duplicate_convict, current_organization).call
    @show_divestment_button = decision[:show_button]
    @duplicate_alert = decision[:alert]
  end

  def find_duplicate_convict # rubocop:disable Metrics/AbcSize
    if @convict.errors.where(:appi_uuid, :taken).any?
      Convict.find_by(appi_uuid: @convict.appi_uuid)
    elsif @convict.errors.where(:phone, t('activerecord.errors.models.convict.attributes.phone.taken')).any?
      Convict.find_by(phone: @convict.phone)
    elsif @convict.errors.where(:date_of_birth, :taken).any?
      Convict.where(first_name: @convict.first_name, last_name: @convict.last_name,
                    date_of_birth: @convict.date_of_birth, appi_uuid: [nil, '']).first
    end
  end

  def divestment_button_checks
    @duplicate_alert = ''

    if @duplicate_convict&.organizations&.include?(current_organization)
      handle_duplicate_is_under_current_org
    else
      handle_duplicate_is_under_other_org
    end
  end

  def handle_duplicate_is_under_current_org
    @show_divestment_button = false
    org_names = org_names_with_custom_label('votre propre service')
    @duplicate_alert = format_duplicate_alert_string(org_names)
  end

  def handle_duplicate_is_under_other_org
    pending_divestment_and_future_appointments
    @show_divestment_button = @pending_divestment.nil? && @future_appointments.none?

    @duplicate_alert = if @pending_divestment.present?
                         @show_pending_divestment_notice =
                           "Le probationnaire #{@duplicate_convict.full_name} fait \
                           déjà l'objet d'une demande de dessaisissement \
                           de la part de #{@pending_divestment.organization.name} \
                           (#{@pending_divestment.organization.places.first&.phone})."
                       else
                         org_names = formatted_organization_names_and_phones
                         @duplicate_alert = format_duplicate_alert_string(org_names)
                       end
  end

  def org_names_with_custom_label(custom_label)
    @duplicate_convict.organizations.map do |org|
      org == current_organization ? custom_label : org.name
    end
  end

  def format_duplicate_alert_string(org_names)
    return org_names.first.to_s if org_names.length <= 1

    last = org_names.pop
    "#{@duplicate_convict.full_name} suivi par #{org_names.join(', ')} ainsi que #{last}"
  end

  def formatted_organization_names_and_phones
    @duplicate_convict.organizations.map do |org|
      name_and_phone = org.name
      name_and_phone += " (#{org.places.first&.phone})" if org.places.first&.phone.present?
      name_and_phone
    end
  end

  def pending_divestment_and_future_appointments
    @pending_divestment = @duplicate_convict.divestments.find_by(state: 'pending')
    @future_appointments = @duplicate_convict.future_appointments
  end

  def convict_params
    params.require(:convict).permit(
      :first_name, :last_name, :phone, :no_phone,
      :refused_phone, :place_id, :appi_uuid, :user_id, :city_id, :japat, :homeless, :lives_abroad, :date_of_birth
    )
  end

  def select_path(params)
    if params['no-appointment'].nil?
      new_appointment_path(convict_id: @convict.id)
    else
      convicts_path
    end
  end

  def allow_new_phone(old_phone)
    return unless old_phone.blank?
    return unless @convict.no_phone? || @convict.refused_phone?

    @convict.no_phone = false
    @convict.refused_phone = false
    @convict.save
  end

  def record_phone_change(old_phone)
    return if @convict.phone.blank? && old_phone.blank?
    return if @convict.phone == old_phone

    allow_new_phone(old_phone)
    item_event = select_history_item_event(old_phone)

    HistoryItemFactory.perform(
      category: 'convict', convict: @convict, event: item_event,
      data: { old_phone:, user_name: current_user.name, user_role: current_user.role }
    )
  end

  def select_history_item_event(old_phone)
    if old_phone.blank?
      'add_phone_convict'
    elsif @convict.phone.blank?
      'remove_phone_convict'
    else
      'update_phone_convict'
    end
  end

  def update_convict
    @convict.current_user = current_user
    @convict.update_organizations(current_user) if @convict.update(convict_params)
  end

  def handle_successful_update(old_phone)
    record_phone_change(old_phone)
    flash.now[:success] = 'Le probationnaire a bien été mise à jour'
    redirect_to convict_path(@convict)
  end

  def render_new_with_appi_uuid(convict)
    @convict_with_same_appi = Convict.where(appi_uuid: convict.appi_uuid) if convict.errors[:appi_uuid].any?
    render :new, status: :unprocessable_entity
  end

  def add_prefix_to_phone(phone)
    "+33#{phone[1..]}"
  end

  def base_filter
    params[:my_convicts] == '1' ? current_user.convicts : Convict.all
  end

  def fetch_convicts(query)
    scope = policy_scope(base_filter)
    scope = scope.search_by_name_and_phone(query) if query.present?
    scope.order('last_name asc').page params[:page]
  end
end
