class AppointmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = policy_scope(Appointment).active.ransack(params[:q])
    @all_appointments = @q.result(distinct: true)
                          .joins(:convict, slot: [:appointment_type, { agenda: [:place] }])
                          .includes(:convict, :user, slot: [:appointment_type, { agenda: [:place] }])
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

    set_warning_flash_no_city if current_user.can_use_inter_ressort? && !@convict.city_id

    initialize_extra_fields
  end

  def create
    @appointment = Appointment.new(appointment_params)
    assign_appointment_to_user
    assign_appointment_to_creating_organization

    authorize @appointment
    if @appointment.save
      @appointment.convict.update(user: current_user) if params.dig(:appointment, :user_is_cpip) == '1'
      @appointment.update(inviter_user_id: current_user.id)
      @appointment.book(send_notification: params[:send_sms])
      redirect_to appointment_path(@appointment)
    else
      @appointment.errors.each { |error| flash.now[:alert] = error.message }
      @extra_fields = current_user.organization.extra_fields.select(&:appointment_create?)
      render :new
    end
  end

  def cancel
    @appointment = policy_scope(Appointment).find(params[:appointment_id])
    @appointment.cancel send_notification: true

    authorize @appointment
    redirect_back(fallback_location: root_path)
  end

  def fulfil
    @appointment = policy_scope(Appointment).find(params[:appointment_id])
    @appointment.fulfil

    authorize @appointment, :fulfil_old?
    redirect_back(fallback_location: root_path)
  end

  def miss
    @appointment = policy_scope(Appointment).find(params[:appointment_id])
    @appointment.miss(send_notification: params[:send_sms])

    authorize @appointment
    redirect_back(fallback_location: root_path)
  end

  def excuse
    @appointment = policy_scope(Appointment).find(params[:appointment_id])
    @appointment.excuse

    authorize @appointment, :excuse_old?
    redirect_back(fallback_location: root_path)
  end

  def rebook
    @appointment = policy_scope(Appointment).find(params[:appointment_id])
    @appointment.rebook

    authorize @appointment, :rebook_old?
    redirect_back(fallback_location: root_path)
  end

  private

  def appointment_params
    params.require(:appointment).permit(
      :slot_id, :user_id, :convict_id, :appointment_type_id, :place_id, :origin_department, :prosecutor_number,
      :creating_organization_id, slot_attributes: [:id, :agenda_id, :appointment_type_id, :date, :starting_time],
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
                           La prise de RDV ne sera possible que dans votre ressort:
                           <a href='/convicts/#{@convict.id}/edit'>
                          Ajouter une commune à #{@convict.full_name}</a>".html_safe
  end

  def initialize_extra_fields
    @extra_fields = @convict.organizations.tj&.first&.extra_fields&.select(&:appointment_create?)
    @extra_fields&.each { |extra_field| @appointment.appointment_extra_fields.build(extra_field: extra_field) }
  end
end
