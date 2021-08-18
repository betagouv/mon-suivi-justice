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

  def show
    @appointment = Appointment.find(params[:id])
    @convict = @appointment.convict

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
      @appointment.book
      redirect_to appointment_path(@appointment)
    else
      render :new
    end
  end

  def cancel
    @appointment = Appointment.find(params[:appointment_id])
    @appointment.cancel!

    authorize @appointment
    redirect_back(fallback_location: root_path)
  end

  def display_places
    skip_authorization
    @appointment_type = AppointmentType.find(params[:apt_type_id])
    @places = Place.where(place_type: @appointment_type.place_type)

    respond_to do |format|
      format.js
    end
  end

  def display_agendas
    skip_authorization
    place = Place.find(params[:place_id])
    @agendas = Agenda.where(place_id: place.id)

    if @agendas.count == 1
      redirect_to display_slots_path(agenda_id: @agendas.first.id, apt_type_id: params[:apt_type_id])
    end

    respond_to do |format|
      format.js
    end
  end

  def display_slots
    skip_authorization
    agenda = Agenda.find(params[:agenda_id])
    appointment_type = AppointmentType.find(params[:apt_type_id])

    @slots_by_date = Slot.future
                         .relevant_and_available(agenda, appointment_type)
                         .order(:date)
                         .group_by(&:date)

    respond_to do |format|
      format.js
    end
  end

  def index_today
    @q = Appointment.for_today.ransack(params[:q])
    @appointments = @q.result
                      .joins(slot: [agenda: [:place]])
                      .includes(slot: [agenda: [:place]])

    authorize @appointments
  end

  private

  def appointment_params
    params.require(:appointment).permit(:slot_id, :convict_id, :appointment_type_id,
                                        :place_id, :origin_department)
  end
end
