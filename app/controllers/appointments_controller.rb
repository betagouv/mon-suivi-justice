class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :skip_authorization, only: [:display_places, :display_agendas, :display_time_options, :display_is_cpip,
                                            :display_slots, :display_slot_fields]

  def index
    @q = policy_scope(Appointment).active.ransack(params[:q])
    @all_appointments = @q.result(distinct: true)
                          .joins(:convict, slot: [:appointment_type, { agenda: [:place] }])
                          .includes(:convict, slot: [:appointment_type, { agenda: [:place] }])
                          .order('slots.date ASC, slots.starting_time ASC')

    @appointments = @all_appointments.page(params[:page]).per(25)

    respond_to do |format|
      format.html
      format.pdf do
        render template: 'appointments/index_pdf.html.erb',
               pdf: 'Liste des rdv', footer: { right: '[page]/[topage]' }
      end
    end

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

    return unless params.key?(:convict_id)

    @convict = Convict.find(params[:convict_id])
  end

  def create
    @appointment = Appointment.new(appointment_params)

    assign_appointment_to_user

    authorize @appointment
    if @appointment.save
      @appointment.convict.update(user: current_user) if params.dig(:appointment, :user_is_cpip) == '1'
      @appointment.book(send_notification: params[:send_sms])
      redirect_to appointment_path(@appointment)
    else
      @appointment.errors.each { |error| flash[:alert] = error.message }
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

  def rebook
    @appointment = policy_scope(Appointment).find(params[:appointment_id])
    @appointment.rebook!

    authorize @appointment
    redirect_back(fallback_location: root_path)
  end

  def display_places
    @appointment_type = AppointmentType.find(params[:apt_type_id])
    @places = policy_scope(Place).joins(:appointment_types).where(appointment_types: @appointment_type)
  end

  def display_is_cpip
    @convict = params[:convict_id].present? ? Convict.find(params[:convict_id]) : nil
  end

  def display_agendas
    place = policy_scope(Place).find(params[:place_id])
    @agendas = Agenda.where(place_id: place.id)
    @appointment_type = AppointmentType.find(params[:apt_type_id])

    return unless @agendas.count == 1

    redirect_to display_time_options_path(place_id: place.id,
                                          agenda_id: @agendas.first.id,
                                          apt_type_id: params[:apt_type_id])
  end

  def display_time_options
    all_agendas = params[:agenda_id] == 'all'
    agenda_id = params[:agenda_id] == 'all' ? nil : policy_scope(Agenda).find(params[:agenda_id]).id

    @appointment_type = AppointmentType.find(params[:apt_type_id])

    if @appointment_type.with_slot_types?
      redirect_to display_slots_path(place_id: params[:place_id],
                                     agenda_id: agenda_id,
                                     all_agendas: all_agendas,
                                     apt_type_id: @appointment_type.id)
    else
      redirect_to display_slot_fields_path(agenda_id: agenda_id, apt_type_id: @appointment_type.id)
    end
  end

  def display_slots
    @appointment_type = AppointmentType.find(params[:apt_type_id])
    @all_agendas = params[:all_agendas] == 'true'

    if @all_agendas
      place = Place.find(params[:place_id])
      @slots_by_date = Slot.future.relevant_and_available_all_agendas(place, @appointment_type)
                           .order(:date).group_by(&:date)
    elsif !params[:agenda_id].nil?
      agenda = policy_scope(Agenda).find(params[:agenda_id])
      @slots_by_date = Slot.future.relevant_and_available(agenda, @appointment_type)
                           .order(:date).group_by(&:date)
    end
  end

  def display_slot_fields
    @agenda = policy_scope(Agenda).find(params[:agenda_id])
    @appointment_type = AppointmentType.find(params[:apt_type_id])
  end

  private

  def appointment_params
    params.require(:appointment).permit(
      :slot_id, :convict_id, :appointment_type_id, :place_id, :origin_department, :prosecutor_number,
      slot_attributes: [:id, :agenda_id, :appointment_type_id, :date, :starting_time]
    )
  end

  def assign_appointment_to_user
    return unless @appointment.slot&.appointment_type&.assignable? && current_user.can_have_appointments_assigned?

    @appointment.user = current_user
  end
end
