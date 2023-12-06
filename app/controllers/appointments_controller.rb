class AppointmentsController < ApplicationController
  include InterRessortFlashes
  include AppointmentsHelper
  before_action :authenticate_user!

  def index
    @search_params = search_params
    @places = policy_scope(Place)
    @agendas = policy_scope(Agenda)
    @q = policy_scope(Appointment).active.ransack(params[:q])
    @all_appointments = @q.result(distinct: true)
                          .joins(:convict, slot: [:appointment_type, { agenda: [:place] }])
                          .includes(:convict, :user, slot: [:appointment_type, { agenda: [:place] }])
                          .order('slots.date ASC, slots.starting_time ASC')

    slots = @all_appointments.map(&:slot).uniq
    @agendas = slots.map(&:agenda).uniq
    @places = @agendas.map(&:place).uniq
    @appointment_types = slots.map(&:appointment_type).uniq
    @users = @all_appointments.map(&:user).uniq.compact
    @users.delete(current_user)

    @users.unshift(current_user) if current_user.can_have_appointments_assigned?

    @appointments = @all_appointments.page(params[:page]).per(25)

    respond_to do |format|
      format.html
      format.pdf do
        render template: 'appointments/index_pdf',
               pdf: 'Liste des convocations', footer: { right: '[page]/[topage]' }, formats: [:html]
      end
    end

    authorize @appointments
  end

  def show
    @appointment = Appointment.find(params[:id])
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
    @appointment_types = appointment_types_for_user(current_user)
    set_inter_ressort_flashes if current_user.can_use_inter_ressort?

    set_extra_fields
    build_appointment_extra_fields
  end

  def create
    @appointment = Appointment.new(appointment_params)
    assign_appointment_to_user
    assign_appointment_to_creating_organization

    authorize @appointment

    if @appointment.save
      @appointment.convict.update(user: current_user) if params.dig(:appointment, :user_is_cpip) == '1'
      @appointment.update(inviter_user_id: current_user.id)
      @appointment.book(send_notification: @appointment.send_sms)
      redirect_to appointment_path(@appointment)
    else
      selected_place = Place.find(params.dig(:appointment, :place_id))

      build_error_messages(selected_place)

      @convict = Convict.find(params.dig(:appointment, :convict_id))
      @appointment_types = appointment_types_for_user(current_user)

      # We need to set the extra fields but we don't want to build them again
      set_extra_fields
      render :new, status: :unprocessable_entity
    end
  end

  def cancel
    @appointment = Appointment.find(params[:appointment_id])
    authorize @appointment
    @appointment.cancel send_notification: true

    redirect_back(fallback_location: root_path)
  end

  def fulfil
    @appointment = Appointment.find(params[:appointment_id])
    authorize @appointment, :fulfil_old?
    @appointment.fulfil

    redirect_back(fallback_location: root_path)
  end

  def miss
    @appointment = Appointment.find(params[:appointment_id])
    authorize @appointment
    @appointment.miss(send_notification: params[:send_sms])

    redirect_back(fallback_location: root_path)
  end

  def excuse
    @appointment = Appointment.find(params[:appointment_id])
    authorize @appointment, :excuse_old?
    @appointment.excuse

    redirect_back(fallback_location: root_path)
  end

  def rebook
    @appointment = Appointment.find(params[:appointment_id])
    authorize @appointment, :rebook_old?
    @appointment.rebook

    redirect_back(fallback_location: root_path)
  end

  private

  def search_params
    params.fetch(:q, {}).permit(:slot_date_eq, :slot_agenda_place_id_eq, :slot_agenda_id_eq,
                                :slot_appointment_type_id_eq, :user_id_eq)
  end

  def appointment_params
    params.require(:appointment).permit(
      :slot_id, :user_id, :convict_id, :appointment_type_id, :place_id, :origin_department, :prosecutor_number,
      :creating_organization_id, :send_sms,
      slot_attributes: [:id, :agenda_id, :appointment_type_id, :date, :starting_time],
      appointment_extra_fields_attributes: [:value, :extra_field_id]
    )
  end

  def assign_appointment_to_user
    return unless @appointment.slot&.appointment_type&.assignable? && current_user.can_have_appointments_assigned?

    @appointment.user = current_user
  end

  def assign_appointment_to_creating_organization
    @appointment.creating_organization = current_user.organization
  end

  def set_warning_flash_no_city
    flash.now[:warning] = "<strong>ATTENTION. Aucune commune renseignée.</strong>
                           Convocation possible uniquement dans votre ressort:
                           <a href='/convicts/#{@convict.id}/edit'>
                          Ajouter une commune à #{@convict.full_name}</a>".html_safe
  end

  def set_extra_fields
    return unless @convict

    @extra_fields = @convict.organizations.includes([:extra_fields]).flat_map do |org|
      org.extra_fields.select(&:appointment_create?)
    end
  end

  def build_appointment_extra_fields
    @extra_fields&.each { |extra_field| @appointment.appointment_extra_fields.build(extra_field:) }
  end

  def build_error_messages(place)
    @appointment.errors.each do |error|
      flash.now[:warning] = if error.attribute.to_s == 'appointment_extra_fields.value' && error.type == :blank
                              "Le(s) champ(s) aditionnel(s) du service #{place.name} doivent être renseignés"
                            else
                              error.message
                            end
    end
  end

  def appointment_types_for_user_places
    # Les agents SAP doivent pouvoir prendre des convocations SAP DDSE au SPIP
    if current_user.work_at_sap?
      user_places = Place.in_jurisdiction(current_user.organization)
    else
      user_places = policy_scope(Place).kept
    end
    AppointmentType.joins(place_appointment_types: :place)
                   .where(places: user_places)
                   .distinct
  end

  def appointment_types_for_user(user)
    available_apt_type = appointment_types_for_user_role(user)
    places_apt_type = appointment_types_for_user_places
    available_apt_type.to_a.intersection(places_apt_type.to_a)
  end
end
