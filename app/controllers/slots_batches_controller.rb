class SlotsBatchesController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def new; end

  def create
    handle_create(params, slot_params)
  rescue StandardError => e
    p e
    handle_create_errors(params, slot_params)
  end

  def handle_create(params, slot_params)
    result = batch_create(params, slot_params)

    if result.all?(&:persisted?)
      flash.discard
      redirect_to slots_path
    else
      handle_create_errors(params, slot_params)
    end
  end

  def handle_create_errors(_params, slot_params)
    flash[:error] = I18n.t('slots.failed_batch_creation')
    @agenda = Agenda.find(slot_params[:agenda_id]) if slot_params[:agenda_id].present?
    if slot_params[:appointment_type_id].present?
      @appointment_type = AppointmentType.find(slot_params[:appointment_type_id])
    end
    @date = slot_params[:date] if slot_params[:date].present?
    render :new, status: :unprocessable_entity
  end

  def update
    slots = Slot.joins(agenda: :place).where(id: params[:slot_ids])
    authorize slots, :update_all?
    slots.update_all(available: false)

    redirect_back(fallback_location: root_path)
  end

  def display_time_fields
    render turbo_stream: turbo_stream.append('display_time_fields', partial: 'time_fields')
  end

  private

  def slot_params
    params.require(:slot_batch).permit(:agenda_id, :appointment_type_id, :date, :available,
                                       :starting_time, :capacity, :duration, starting_times: [])
  end

  def batch_create(params, slot_params)
    times = params.require(:starting_times).each_slice(2).to_a
    dates = slot_params.require(:date).split(', ').map(&:to_date)
    slots_data = []

    dates.each { |date| times.each { |time| slots_data << build_slot(slot_params, date, time) } }

    Slot.create(slots_data)
  end

  def build_slot(params, date, time)
    {
      agenda_id: params[:agenda_id],
      appointment_type_id: params[:appointment_type_id],
      date:,
      starting_time: Time.new(2021, 6, 21, time[0], time[1], 0, current_time_zone),
      capacity: params[:capacity],
      duration: params[:duration]
    }
  end
end
