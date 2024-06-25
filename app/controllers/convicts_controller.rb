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
    @convicts = fetch_convicts

    authorize @convicts
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
    instantiate_convict
    authorize @convict

    if @convict.save
      handle_convict_interface_invitation
      redirect_to select_path(params), notice: t('.notice')
    else
      @duplicate_convicts = @convict.find_duplicates

      divestment_proposal if @duplicate_convicts.present?

      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @convict = policy_scope(Convict).find(params[:id])
    @saved_japat_value = @convict.japat
    @saved_convict_city = @convict.city
    @saved_convict_organizations = @convict.organizations
    set_inter_ressort_flashes if current_user.can_use_inter_ressort?

    authorize @convict
  end

  def update
    @convict = policy_scope(Convict).find(params[:id])
    authorize @convict

    old_phone = @convict.phone
    @saved_japat_value = @convict.japat
    @saved_convict_city = @convict.city
    @saved_convict_organizations = [*@convict.organizations]

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
    @convict.update_organizations(current_user) if @convict.update(convict_params)
  end

  def handle_successful_update(old_phone)
    record_phone_change(old_phone)
    if !convict.japat? && organizations_changed?
      origin = divestment_origin

      divestment = Divestment.new user: current_user, organization: origin, convict: @convict
      divestment_creation = DivestmentCreatorService.new(@convict, current_user, divestment).call
    end
    flash.now[:success] = 'Le probationnaire a bien été mise à jour'
    redirect_to convict_path(@convict)
  end

  def add_prefix_to_phone(phone)
    "+33#{phone[1..].gsub(/[^0-9]/, '')}"
  end

  def base_filter
    params[:my_convicts] == '1' ? current_user.convicts : Convict.all
  end

  def fetch_convicts(query = nil)
    scope = policy_scope(base_filter)
    scope = scope.search_by_name_and_phone(query) if query.present?
    scope.order('last_name asc').page params[:page]
  end

  def instantiate_convict
    @convict = Convict.new(convict_params)
    @convict.creating_organization = current_organization
    @convict.current_user = current_user
    @convict.update_organizations(current_user, autosave: false)
  end

  def handle_convict_interface_invitation
    return unless params[:invite_convict] == 'on' && ConvictInvitationPolicy.new(current_user, @convict).create?

    InviteConvictJob.perform_later(@convict.id)
  end

  def organizations_changed?
    @saved_convict_organizations.present? && @saved_convict_organizations != @convict.organizations
  end

  def divestment_origin
    diff = @convict.organizations - @saved_convict_organizations
    tj = diff.find { |org| org.tj? } 
    spip = diff.find { |org| org.spip? }
    return tj || spip
  end
end
