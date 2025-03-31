class ConvictsController < ApplicationController
  include InterRessortFlashes

  before_action :authenticate_user!

  def show
    @convict = policy_scope(Convict).find(params[:id])
    @history_items = HistoryItem.where(convict: @convict, category: %w[appointment convict])
                                .includes(:appointment)
                                .order(created_at: :desc)
    @booked_appointments = @convict.booked_appointments.includes(:creating_organization, slot: { agenda: :place })
    @future_appointments_and_excused = @convict.future_appointments_and_excused
                                               .includes(slot: { agenda: :place, appointment_type: {} })

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

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create
    instantiate_convict
    authorize @convict
    @duplicate_convicts = @convict.find_dup_with_full_name_and_dob if @convict.valid? && !params[:force_create]

    if @duplicate_convicts.blank? && @convict.save
      redirect_to select_path(params), notice: t('.notice')
    else
      @allow_force_create = @duplicate_convicts.present?
      @duplicate_convicts ||= @convict.find_duplicates
      divestment_proposal if @duplicate_convicts.present? && !current_user.can_use_inter_ressort?

      render :new, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def edit
    @convict = policy_scope(Convict).find(params[:id])
    @saved_japat_value = @convict.japat

    set_inter_ressort_flashes if current_user.can_use_inter_ressort?

    authorize @convict
  end

  def update
    @convict = policy_scope(Convict).find(params[:id])
    authorize @convict

    old_phone = @convict.phone
    @saved_japat_value = @convict.japat
    handle_city_change
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

  def accept_phone
    @convict = Convict.find(params[:id])
    authorize @convict

    if @convict.accept_phone
      redirect_to convict_path(@convict), notice: t('.notice')
    else
      redirect_to convict_path(@convict),
                  alert: t('.alert')
    end
  end

  private

  def divestment_proposal
    @dups_details = DivestmentProposalService.new(@duplicate_convicts, current_organization).call
  end

  def convict_params
    params.require(:convict).permit(
      :first_name, :last_name, :phone, :no_phone,
      :refused_phone, :place_id, :appi_uuid, :user_id, :city_id,
      :japat, :homeless, :lives_abroad, :date_of_birth
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
    japat_changed = @convict.japat != convict_params[:japat]
    return unless @convict.update(convict_params)

    return unless japat_changed || new_convict_city.present?

    @convict.update_organizations(current_user)
  end

  def handle_successful_update(old_phone)
    record_phone_change(old_phone)
    create_divestment_proposal
    flash.now[:success] = 'Le probationnaire a bien été mise à jour'
    redirect_to convict_path(@convict)
  end

  def add_prefix_to_phone(phone)
    "+33#{phone[1..].gsub(/[^0-9]/, '')}"
  end

  def base_filter
    if current_user.can_follow_convict? && params[:my_convicts] == '1'
      current_user.convicts
    elsif current_user.work_at_bex? && params[:organization_convicts] == '1'
      current_user.organization.convicts
    else
      Convict.all
    end
  end

  def fetch_convicts(query = nil)
    scope = policy_scope(base_filter)
    scope = scope.search_by_name_and_phone(query) if query.present?
    scope.reorder('convicts.last_name asc, convicts.first_name asc').includes(:organizations, :user).page params[:page]
  end

  def instantiate_convict
    @convict = Convict.new(convict_params)
    @convict.creating_organization = current_organization
    @convict.current_user = current_user
    @convict.unsubscribe_token = Convict.generate_unsubscribe_token
    @convict.update_organizations(current_user, autosave: false)
  end

  def create_divestment_proposal
    return unless !@convict.japat? && @new_convict_city.present?

    divestment_origin = @new_convict_city.tj_organization || @new_convict_city.spip_organization
    divestment = Divestment.new user: current_user, organization: divestment_origin, convict: @convict
    DivestmentCreatorService.new(@convict, current_user, divestment, @new_convict_city.organizations).call
  end

  def handle_city_change
    return unless convict_params.present?

    new_city_id = convict_params[:city_id]
    @new_convict_city = City.find(new_city_id) if new_city_id.present? && new_city_id != @convict.city_id&.to_s
  end
end
