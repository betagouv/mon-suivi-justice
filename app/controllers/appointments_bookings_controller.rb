class AppointmentsBookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :skip_authorization

  def load_places
    @appointment_type = AppointmentType.find(params[:apt_type_id])
    @convict = Convict.find(params[:convict_id])

    # Load places
    @places = Place.kept.joins(:appointment_types, organization: :convicts)
                   .where('convicts.id': @convict.id).where(appointment_types: @appointment_type)
  end

  def load_prosecutor
    @appointment_type = AppointmentType.find(params[:apt_type_id])
  end

  def load_is_cpip
    @convict = params[:convict_id].present? ? Convict.find(params[:convict_id]) : nil

    return if @convict.city_id
  end

  def load_agendas
    @place = Place.find(params[:place_id])
    @agendas = Agenda.kept.where(place_id: @place.id)
    @appointment_type = AppointmentType.find(params[:apt_type_id])
    return unless @agendas.count == 1

    redirect_to load_time_options_path(place_id: @place.id,
                                       agenda_id: @agendas.first.id,
                                       apt_type_id: params[:apt_type_id])
  end

  def load_time_options
    all_agendas = params[:agenda_id] == 'all'
    agenda_id = params[:agenda_id] == 'all' ? nil : params[:agenda_id]

    @appointment_type = AppointmentType.find(params[:apt_type_id])
    if @appointment_type.with_slot_types?
      redirect_to load_slots_path(place_id: params[:place_id],
                                  agenda_id:,
                                  all_agendas:,
                                  apt_type_id: @appointment_type.id)
    else
      redirect_to load_slot_fields_path(agenda_id:, apt_type_id: @appointment_type.id)
    end
  end

  def load_slots
    @appointment_type = AppointmentType.find(params[:apt_type_id])
    @all_agendas = params[:all_agendas] == 'true'

    if @all_agendas
      place = Place.find(params[:place_id])
      @slots_by_date = Slot.future.relevant_and_available_all_agendas(place, @appointment_type)
                           .order(:date).group_by(&:date)
    elsif !params[:agenda_id].nil?
      agenda = Agenda.find(params[:agenda_id])
      @slots_by_date = Slot.future.relevant_and_available(agenda, @appointment_type)
                           .order(:date).group_by(&:date)
    end
  end

  def load_slot_fields
    @agenda = policy_scope(Agenda).find(params[:agenda_id])
    @appointment_type = AppointmentType.find(params[:apt_type_id])
  end

  def load_submit_button
    @convict = Convict.find(params[:convict_id])
  end
end
