class BexController < ApplicationController
  before_action :authenticate_user!
  before_action :appointment_type
  before_action :month, only: :agenda_jap
  skip_after_action :verify_authorized

  def agenda_jap
    authorize Appointment
    @current_date = current_date(@appointment_type, params)
    get_places_and_agendas(@appointment_type, params)
    @extra_fields = @agenda&.organization&.extra_fields_for_agenda&.includes(:appointment_types)&.related_to_sap

    respond_to do |format|
      format.html
      format.pdf do
        render template: 'bex/agenda_jap_pdf', locals: { date: @current_date },
               pdf: "Agenda sortie d'audience JAP", footer: { right: '[page]/[topage]' },
               orientation: 'Landscape', formats: [:html]
      end
    end
  end

  def agenda_spip
    authorize Appointment
    @current_date = current_date(@appointment_type, params)
    get_places_and_agendas(@appointment_type, params)
    @extra_fields = @agenda&.organization&.extra_fields_for_agenda&.includes(:appointment_types)&.related_to_spip # rubocop:disable Style/SafeNavigationChainLength

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Agenda sortie d'audience SPIP", template: 'bex/agenda_spip_pdf', locals: { date: @current_date },
               formats: [:html], footer: { right: '[page]/[topage]' },
               orientation: 'Landscape'
      end
    end
  end

  def agenda_sap_ddse
    authorize Appointment
    @current_date = current_date(@appointment_type, params)
    get_places_and_agendas(@appointment_type, params)

    respond_to(&:html)
  end

  def appointment_extra_field
    appointment_extra_field = AppointmentExtraField.find_or_initialize_by(appointment_id: params[:appointment_id],
                                                                          extra_field_id: params[:extra_field_id])
    appointment_extra_field.value = params[:value]
    appointment_extra_field.save(validate: true)
  end

  private

  def month
    params[:month] ||= Time.zone.today.to_fs
  end

  def appointment_type
    @appointment_type = AppointmentType.find_by(name: params[:appointment_type])
  end

  def current_date(appointment_type, params)
    if params.key?(:date) && !params[:date].empty?
      params[:date].to_date
    elsif current_organization.first_day_with_slots(appointment_type).nil?
      Time.zone.today
    else
      current_organization.first_day_with_slots(appointment_type)
    end
  end

  def places(appointment_type)
    place_policy_scope_for_bex.kept.joins(:appointment_types).where(appointment_types: appointment_type)
  end

  def get_places_and_agendas(appointment_type, params) # rubocop:disable Metrics/AbcSize
    @places = place_policy_scope_for_bex.kept.joins(:appointment_types).where(appointment_types: appointment_type)
    @place = params[:place_id] ? Place.find(params[:place_id]) : @places.first
    @agendas = policy_scope(Agenda).includes(:place)
                                   .where(place: @place).with_open_slots(appointment_type).sort_by(&:name)
    @agenda = params[:agenda_id].nil? ? @agendas.first : Agenda.find(params[:agenda_id])
  end

  def days_with_slots(appointment_type, month)
    Slot.future
        .in_organization(current_organization)
        .available_or_with_appointments(month.to_date.all_month.to_a, appointment_type)
        .pluck(:date)
        .uniq
        .sort
  end

  def selected_day(days_with_slots_in_selected_month, params)
    if params[:date]&.present? && days_with_slots_in_selected_month.include?(params[:date].to_date)
      params[:date].to_date.to_fs
    else
      days_with_slots_in_selected_month.first&.to_fs
    end
  end

  def place_policy_scope_for_bex
    policy_scope(Place, policy_scope_class: BexPolicy::Scope)
  end
end
