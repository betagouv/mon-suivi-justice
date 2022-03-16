class BexController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def agenda_jap
    @appointment_type = AppointmentType.find_by(name: "Sortie d'audience SAP")
    @current_date = current_date(@appointment_type, params)
    @agendas = policy_scope(Agenda).with_open_slots_for_date(@current_date, @appointment_type)
  end

  def agenda_spip
    @appointment_type = AppointmentType.find_by(name: "Sortie d'audience SPIP")
    @current_date = current_date(@appointment_type, params)
    @agenda = policy_scope(Agenda).with_open_slots(@appointment_type).first
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
