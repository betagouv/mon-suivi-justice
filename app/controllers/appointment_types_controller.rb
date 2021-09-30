class AppointmentTypesController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = AppointmentType.order('name asc').ransack(params[:q])
    @appointment_types = @q.result(distinct: true)
    authorize @appointment_types
  end

  def edit
    @appointment_type = AppointmentType.find(params[:id])
    authorize @appointment_type
  end

  def update
    @appointment_type = AppointmentType.find(params[:id])
    authorize @appointment_type

    if @appointment_type.update(appointment_type_params)
      redirect_to appointment_types_path
    else
      render :edit
    end
  end

  private

  def appointment_type_params
    params.require(:appointment_type).permit(
      :name, notification_types_attributes: [:id, :template, :reminder_period]
    )
  end
end
