class BexController < ApplicationController
  before_action :authenticate_user!

  def agenda_jap
    @appointment_type = AppointmentType.find_by(name: "Sortie d'audience SAP")
    @current_date = current_date(@appointment_type, params)
    @agendas = Agenda.in_organization(current_organization).with_open_slots_for_date(@current_date, @appointment_type)
    @appointments = policy_scope(Appointment).for_a_date(@current_date).active
                                             .joins(slot: [:appointment_type, :agenda])
                                             .where('slots.appointment_type_id = ?', @appointment_type.id)
                                             .group('appointments.id,agendas.name')
    authorize @appointments
  end

  def agenda_spip
    @appointment_type = AppointmentType.find_by(name: "Sortie d'audience SPIP")
    @current_date = current_date(@appointment_type, params)
    @agenda = Agenda.in_organization(current_organization).with_open_slots(@appointment_type).first
    @appointments = policy_scope(Appointment).for_a_month(@current_date).active
                                             .joins(slot: [:appointment_type, :agenda])
                                             .where('slots.appointment_type_id = ?', @appointment_type.id)
    authorize @appointments
  end

  private

  def current_date(appointment_type, params)
    if params.key?(:date)
      params[:date].to_date
    elsif current_organization.first_day_with_slots(appointment_type).nil?
      Date.today
    else
      current_organization.first_day_with_slots(appointment_type)
    end
  end
end
