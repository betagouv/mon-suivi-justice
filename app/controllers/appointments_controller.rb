class AppointmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @appointments = Appointment.all
    authorize @appointments
  end

  def new_first
    @appointment = Appointment.new
    @place = Place.find(params[:place_id])

    authorize @appointment
  end

  def create
    @appointment = Appointment.new(appointment_params)
    authorize @appointment

    if @appointment.save
      redirect_to appointments_path
    else
      render :new_first
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:slot_id, :convict_id)
  end
end
