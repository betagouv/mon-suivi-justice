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

  def new
    @appointment = Appointment.new

    authorize @appointment
  end

  def create
    @appointment = Appointment.new(appointment_params)
    authorize @appointment

    if @appointment.save
      @appointment.slot.update(available: false)
      redirect_to appointments_path
    else
      render :new_first
    end
  end

  def select_slot
    skip_authorization
    @place = Place.find(params[:place_id])

    respond_to do |format|
      format.js
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:slot_id, :convict_id, :appointment_type_id)
  end
end
