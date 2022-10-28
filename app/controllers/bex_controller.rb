class BexController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def agenda_jap
    @appointment_type = AppointmentType.find_by(name: "Sortie d'audience SAP")
    @current_date = current_date(@appointment_type, params)
    @agendas = policy_scope(Agenda).kept.with_open_slots_for_date(@current_date, @appointment_type)

    respond_to do |format|
      format.html
      format.pdf do
        render template: 'bex/agenda_jap_pdf.html.erb', locals: { date: @current_date },
               pdf: "Agenda sortie d'audience JAP", footer: { right: '[page]/[topage]' }
      end
    end
  end

  def agenda_spip
    @appointment_type = AppointmentType.find_by(name: "Sortie d'audience SPIP")
    @current_date = current_date(@appointment_type, params)
    get_places_and_agendas(@appointment_type, params)

    respond_to do |format|
      format.html
      format.pdf do
        render template: 'bex/agenda_spip_pdf.html.erb', locals: { date: @current_date },
               pdf: "Agenda sortie d'audience SPIP", footer: { right: '[page]/[topage]' }
      end
    end
  end

  def agenda_sap_ddse
    @appointment_type = AppointmentType.find_by(name: 'SAP DDSE')
    @current_date = current_date(@appointment_type, params)
    @agendas = policy_scope(Agenda).with_open_slots_for_date(@current_date, @appointment_type)

    respond_to do |format|
      format.html
      format.pdf do
        render template: 'bex/agenda_sap_ddse_pdf.html.erb', locals: { date: @current_date },
               pdf: 'Agenda SAP DDSE', footer: { right: '[page]/[topage]' }
      end
    end
  end

  private

  def current_date(appointment_type, params)
    if params.key?(:date) && !params[:date].empty?
      params[:date].to_date
    elsif current_organization.first_day_with_slots(appointment_type).nil?
      Date.today
    else
      current_organization.first_day_with_slots(appointment_type)
    end
  end

  def get_places_and_agendas(appointment_type, params)
    @places = policy_scope(Place).kept.joins(:appointment_types).where(appointment_types: appointment_type)
    @place = params[:place_id] ? Place.find(params[:place_id]) : @places.first

    @agendas = policy_scope(Agenda).where(place: @place).with_open_slots(appointment_type)
    @agenda = params[:agenda_id] ? Agenda.find(params[:agenda_id]) : @agendas.first
  end
end
