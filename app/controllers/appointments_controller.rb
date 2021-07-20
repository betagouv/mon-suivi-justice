class AppointmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = Appointment.ransack(params[:q])
    @appointments = @q.result(distinct: true)
                      .includes(:convict, slot: [agenda: [:place]])
                      .joins(:convict, slot: [agenda: [:place]])
                      .page params[:page]
    authorize @appointments
  end

  def index_today
    @q = Appointment.for_today.ransack(params[:q])
    @appointments = @q.result
                      .joins(slot: [agenda: [:place]])
                      .includes(slot: [agenda: [:place]])

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
    @agenda = Agenda.find(params[:agenda_id])
    @appointment_type = AppointmentType.find(params[:apt_type_id])

    respond_to do |format|
      format.js
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:slot_id, :convict_id, :appointment_type_id)
  end
end
