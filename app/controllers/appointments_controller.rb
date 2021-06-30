class AppointmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = Appointment.ransack(params[:q])
    @appointments = @q.result(distinct: true)
                      .includes(slot: [:place])
                      .joins(slot: [:place])
                      .page params[:page]
    authorize @appointments
  end

  def index_today
    @q = Appointment.where(slot: Slot.where(date: Date.today))
                    .ransack(params[:q])
    @appointments = @q.result(distinct: true)
                      .includes(slot: [:place])
                      .joins(slot: [:place])
                      .order("appointment_slot.starting_time desc")

    authorize @appointments
  end

  def new
    @appointment = Appointment.new

    authorize @appointment
  end

  def create
    @appointment = Appointment.new(appointment_params)
    authorize @appointment

    if @appointment.save
      @appointment.book
      redirect_to appointments_path
    else
      render :new
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
