class AppointmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = policy_scope(Appointment).active.ransack(params[:q])
    @appointments = @q.result(distinct: true)
                      .joins(:convict, slot: [agenda: [:place]])
                      .includes(:convict, slot: [agenda: [:place]])
                      .page params[:page]

    authorize @appointments
  end

  def show
    @appointment = policy_scope(Appointment).find(params[:id])
    @convict = @appointment.convict
    @history_items = HistoryItem.where(appointment: @appointment)
                                .order(created_at: :desc)
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
      @appointment.book(send_notification: params[:send_sms])
      redirect_to appointment_path(@appointment)
    else
      render :new
    end
  end

  def cancel
    @appointment = policy_scope(Appointment).find(params[:appointment_id])
    @appointment.cancel! send_notification: true

    authorize @appointment
    redirect_back(fallback_location: root_path)
  end

  def fulfil
    @appointment = policy_scope(Appointment).find(params[:appointment_id])
    @appointment.fulfil!

    authorize @appointment
    redirect_back(fallback_location: root_path)
  end

  def miss
    @appointment = policy_scope(Appointment).find(params[:appointment_id])
    @appointment.miss!(send_notification: params[:send_sms])

    authorize @appointment
    redirect_back(fallback_location: root_path)
  end

  def excuse
    @appointment = policy_scope(Appointment).find(params[:appointment_id])
    @appointment.excuse!

    authorize @appointment
    redirect_back(fallback_location: root_path)
  end

  def display_places
    skip_authorization
    appointment_type = AppointmentType.find(params[:apt_type_id])
    @places = policy_scope(Place).joins(:appointment_types).where(appointment_types: appointment_type)

    respond_to do |format|
      format.js
    end
  end

  def display_agendas
    skip_authorization
    place = policy_scope(Place).find(params[:place_id])
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
    agenda = policy_scope(Agenda).find(params[:agenda_id])
    @appointment_type = AppointmentType.find(params[:apt_type_id])

    @slots_by_date = Slot.future
                         .relevant_and_available(agenda, @appointment_type)
                         .order(:date)
                         .group_by(&:date)

    respond_to do |format|
      format.js
    end
  end

  def index_today
    @q = policy_scope(Appointment).active.for_today.ransack(params[:q])
    @appointments = @q.result
                      .joins(slot: [agenda: [:place]])
                      .includes(slot: [agenda: [:place]])

    authorize @appointments
  end

  private

  def appointment_params
    params.require(:appointment).permit(
      :slot_id, :convict_id, :appointment_type_id, :place_id, :origin_department
    )
  end
end
