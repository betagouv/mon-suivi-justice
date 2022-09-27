class AppointmentsBookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :skip_authorization

  def load_places
    @appointment_type = AppointmentType.find(params[:apt_type_id])

    @places = if params[:department_id].present?
                department = Department.where(id: params[:department_id])
                Place.in_departments(department)
                     .joins(:appointment_types)
                     .where(appointment_types: @appointment_type)
              else
                policy_scope(Place).joins(:appointment_types)
                                   .where(appointment_types: @appointment_type)
              end
  end

  def load_is_cpip
    @convict = params[:convict_id].present? ? Convict.find(params[:convict_id]) : nil
  end

  def load_agendas
    place = Place.find(params[:place_id])
    @agendas = Agenda.where(place_id: place.id)
    @appointment_type = AppointmentType.find(params[:apt_type_id])

    return unless @agendas.count == 1

    redirect_to load_time_options_path(place_id: place.id,
                                       agenda_id: @agendas.first.id,
                                       apt_type_id: params[:apt_type_id])
  end

  def load_departments
    @departments = Department.joins(:organizations).distinct
  end

  def load_time_options
    all_agendas = params[:agenda_id] == 'all'
    agenda_id = params[:agenda_id] == 'all' ? nil : params[:agenda_id]

    @appointment_type = AppointmentType.find(params[:apt_type_id])

    if @appointment_type.with_slot_types?
      redirect_to load_slots_path(place_id: params[:place_id],
                                  agenda_id: agenda_id,
                                  all_agendas: all_agendas,
                                  apt_type_id: @appointment_type.id)
    else
      redirect_to load_slot_fields_path(agenda_id: agenda_id, apt_type_id: @appointment_type.id)
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
