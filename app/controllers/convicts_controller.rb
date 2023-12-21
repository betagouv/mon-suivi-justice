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

    respond_to do |format|
      format.html
      format.turbo_stream
    end
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

    save_and_redirect(@convict)
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

  def save_and_redirect(convict)
    if duplicate_present?(convict) && !force_duplication?
      render :new, status: :unprocessable_entity
    else
      handle_save_and_redirect(convict)
    end
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

  def duplicate_present?(convict)
    convict.check_duplicates
    convict.duplicates.present?
  end

  def force_duplication?
    ActiveRecord::Type::Boolean.new.deserialize(params.dig(:convict, :force_duplication))
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

  def handle_save_and_redirect(convict)
    if convict.update_organizations(current_user)
      redirect_to select_path(params)
    else
      render_new_with_appi_uuid(convict)
    end
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
