class AppointmentTypesController < ApplicationController
  def index
    @q = AppointmentType.ransack(params[:q])
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

    if @appointment_type.update(place_params)
      redirect_to appointment_types_path
    else
      render :edit
    end
  end

  private

  def place_params
    params.require(:appointment_type).permit(
      :name, :place_type,
      notification_types_attributes: [:id, :template, :reminder_period],
      slot_types_attributes: [:id, :week_day, :starting_time, :duration, :capacity, :_destroy]
    )
  end
end
