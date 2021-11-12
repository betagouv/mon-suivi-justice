class ConvictsController < ApplicationController
  before_action :authenticate_user!

  def index
    @all_convicts = policy_scope(Convict)
    @q = policy_scope(Convict).order('last_name asc').ransack(params[:q])
    @convicts = @q.result(distinct: true).page params[:page]

    authorize @all_convicts
    authorize @convicts
  end

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

    if @convict.update(convict_params)
      redirect_to convict_path(@convict)
    else
      render :edit
    end
  end

  def destroy
    @convict = policy_scope(Convict).find(params[:id])
    authorize @convict

    @convict.destroy
    redirect_to convicts_path
  end

  def show
    @convict = policy_scope(Convict).find(params[:id])
    @history_items = HistoryItem.where(convict: @convict, category: 'appointment')
                                .order(created_at: :desc)

    authorize @convict
  end

  private

  def save_and_redirect(convict)
    @duplicate_presence = duplicate_convict_presence
    force_duplication = ActiveRecord::Type::Boolean.new.deserialize(params.dig(:convict, :force_duplication))
    render(:new) && return if @duplicate_presence && !force_duplication

    if convict.save
      # Wil register the new convict in every department/juridiction of current_user's organization areas
      RegisterLegalAreas.for_convict convict, from: current_organization
      redirect_to select_path(params)
    else
      render :new
    end
  end

  def duplicate_convict_presence
    Convict.exists?(
      [
        'lower(first_name) = ? AND lower(last_name) = ?',
        convict_params[:first_name].downcase,
        convict_params[:last_name].downcase
      ]
    )
  end

  def convict_params
    params.require(:convict).permit(
      :first_name, :last_name, :title, :phone, :no_phone,
      :refused_phone, :place_id, :prosecutor_number, :appi_uuid
    )
  end

  def select_path(params)
    if params['no-appointment'].nil?
      new_appointment_path(convict_id: @convict.id)
    else
      convicts_path
    end
  end
end
