class BexController < ApplicationController
  before_action :authenticate_user!
  before_action :appointment_type
  before_action :month, only: :agenda_jap
  skip_after_action :verify_authorized

  def agenda_jap
    get_jap_agendas(@appointment_type, params)

    @days_with_slots_in_selected_month = days_with_slots(@appointment_type, params[:month])
    @selected_day = selected_day(@days_with_slots_in_selected_month, params)

    respond_to do |format|
      format.html
      format.pdf do
        render template: 'bex/agenda_jap_pdf.html.erb', locals: { date: @selected_day },
               pdf: "Agenda sortie d'audience JAP", footer: { right: '[page]/[topage]' },
               orientation: 'Landscape'
      end
    end
  end

  def agenda_spip
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
    authorize Appointment
    @current_date = current_date(@appointment_type, params)
    get_places_and_agendas(@appointment_type, params)

    respond_to do |format|
      format.html
      format.pdf do
        render template: 'bex/agenda_sap_ddse_pdf.html.erb', locals: { date: @current_date },
               pdf: 'Agenda SAP DDSE', footer: { right: '[page]/[topage]' }
      end
    end
  end

  private

  def month
    params[:month] ||= Date.today
  end

  def appointment_type
    @appointment_type = AppointmentType.find_by(name: params[:appointment_type])
  end

  def current_date(appointment_type, params)
    if params.key?(:date) && !params[:date].empty?
      params[:date].to_date
    elsif current_organization.first_day_with_slots(appointment_type).nil?
      Date.today
    else
      current_organization.first_day_with_slots(appointment_type)
    end
  end

  def places(appointment_type)
    policy_scope(Place).kept.joins(:appointment_types).where(appointment_types: appointment_type)
  end

  def get_jap_agendas(appointment_type, params)
    @places_agendas = policy_scope(Agenda).where(place: places(appointment_type)).with_open_slots(appointment_type)
    @selected_agenda = Agenda.find(params[:agenda_id]) unless params[:agenda_id].blank?
    @agendas_to_display = @selected_agenda.nil? ? @places_agendas : [@selected_agenda]
  end

  def get_places_and_agendas(appointment_type, params)
    @places = policy_scope(Place).kept.joins(:appointment_types).where(appointment_types: appointment_type)
    @place = params[:place_id] ? Place.find(params[:place_id]) : @places.first

    @agendas = policy_scope(Agenda).where(place: @place).with_open_slots(appointment_type)
    @agenda = params[:agenda_id].nil? ? @agendas.first : Agenda.find(params[:agenda_id])
  end

  def days_with_slots(appointment_type, month)
    Slot.future
        .in_organization(current_organization)
        .where(appointment_type: appointment_type, date: month.to_date.all_month.to_a)
        .pluck(:date)
        .uniq
        .sort
  end

  def selected_day(days_with_slots_in_selected_month, params)
    if params.key?(:date) && !params[:date].empty? && (params[:date] != params[:day])
      params[:date].to_date
    else
      days_with_slots_in_selected_month.first
    end
  end
end
