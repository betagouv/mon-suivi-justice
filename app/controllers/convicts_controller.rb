class ConvictsController < ApplicationController
  before_action :authenticate_user!

  def show
    @convict = policy_scope(Convict).find(params[:id])
    @history_items = HistoryItem.where(convict: @convict, category: %w[appointment convict])
                                .order(created_at: :desc)

    authorize @convict
  end

  # rubocop:disable Metrics/AbcSize
  def index
    @all_convicts = policy_scope(Convict)
    base_filter = params[:only_mine] == 'true' ? current_user.convicts : Convict.all
    @q = policy_scope(base_filter).order('last_name asc').ransack(params[:q])
    @convicts = @q.result(distinct: true).page params[:page]

    authorize @all_convicts
    authorize @convicts
  end
  # rubocop:enable Metrics/AbcSize

  def new
    @convict = Convict.new
    authorize @convict

    @convict.appointments.build
  end

  def create
    @convict = Convict.new(convict_params)
    authorize @convict
    save_and_redirect @convict
  end

  def edit
    @convict = policy_scope(Convict).find(params[:id])
    authorize @convict
  end

  def update
    @convict = policy_scope(Convict).find(params[:id])
    authorize @convict

    old_phone = @convict.phone

    if @convict.update(convict_params)
      record_phone_change(old_phone)
      redirect_to convict_path(@convict)
    else
      render :edit
    end
  end

  def destroy
    @convict = policy_scope(Convict).find(params[:id])
    authorize @convict

    @convict.destroy!
    redirect_to convicts_path
  end

  def archive
    @convict = policy_scope(Convict).find(params[:convict_id])
    authorize @convict

    @convict.discard
    HistoryItemFactory.perform(convict: @convict, event: 'archive_convict', category: 'convict')
    redirect_back(fallback_location: root_path)
  end

  def unarchive
    @convict = policy_scope(Convict).find(params[:convict_id])
    authorize @convict

    @convict.undiscard
    HistoryItemFactory.perform(convict: @convict, event: 'unarchive_convict', category: 'convict')
    redirect_back(fallback_location: root_path)
  end

  def self_assign
    @convict = policy_scope(Convict).find(params[:convict_id])
    authorize @convict
    @convict.update(user: current_user)

    flash[:notice] = t('.notice')
    redirect_back(fallback_location: root_path)
  end

  private

  def save_and_redirect(convict)
    detect_duplicates(convict)
    force_duplication = ActiveRecord::Type::Boolean.new.deserialize(params.dig(:convict, :force_duplication))
    render(:new) && return if convict.duplicates.present? && !force_duplication

    if convict.save
      RegisterLegalAreas.for_convict convict, from: current_organization
      redirect_to select_path(params)
    else
      render :new
    end
  end

  def detect_duplicates(convict)
    convict.duplicates = if convict.duplicates.present?
                           convict.duplicates.merge(pre_existing_convicts)
                         else
                           pre_existing_convicts
                         end
  end

  def pre_existing_convicts
    Convict.where(
      'lower(first_name) = ? AND lower(last_name) = ?',
      convict_params[:first_name].downcase,
      convict_params[:last_name].downcase
    )
  end

  def convict_params
    params.require(:convict).permit(
      :first_name, :last_name, :phone, :no_phone,
      :refused_phone, :place_id, :appi_uuid, :user_id
    )
  end

  def select_path(params)
    if params['no-appointment'].nil?
      new_appointment_path(convict_id: @convict.id)
    else
      convicts_path
    end
  end

  def record_phone_change(old_phone)
    return if @convict.phone == old_phone || old_phone.blank?

    HistoryItemFactory.perform(
      category: 'convict', convict: @convict, event: 'update_phone_convict',
      data: { old_phone: old_phone, user_name: current_user.name, user_role: current_user.role }
    )
  end
end
