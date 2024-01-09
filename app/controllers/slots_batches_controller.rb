class SlotsBatchesController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def new
    authorize Slot, :new?
  end

  def create
    authorize_batch_create(slot_params)
    handle_create(params, slot_params)
  rescue StandardError => e
    p e
    handle_create_errors(params, slot_params)
  end

  def handle_create(params, slot_params)
    result = batch_create(params, slot_params)

    if result.flatten(1).all?(&:persisted?)
      flash.discard
      redirect_to slots_path
    else
      handle_create_errors(params, slot_params)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def handle_create_errors(_params, slot_params)
    flash[:error] = I18n.t('slots.failed_batch_creation')
    @agenda = Agenda.find(slot_params[:agenda_id]) if slot_params[:agenda_id].present?
    if slot_params[:appointment_type_id].present?
      @appointment_type = AppointmentType.find(slot_params[:appointment_type_id])
    end
    @date = slot_params[:date] if slot_params[:date].present?
    @capacity = slot_params[:capacity] if slot_params[:capacity].present?
    @duration = slot_params[:duration] if slot_params[:duration].present?

    render :new, status: :unprocessable_entity
  end
  # rubocop:enable Metrics/AbcSize

  def update
    slots = Slot.joins(agenda: :place).where(id: params[:slot_ids])
    authorize slots, :update_all?
    slots.update_all(available: false)

    redirect_back(fallback_location: root_path)
  end

  def display_time_fields
    render turbo_stream: turbo_stream.append('display_time_fields', partial: 'time_fields')
  end

  def display_interval_fields
    render turbo_stream: turbo_stream.append('display_time_fields', partial: 'interval_fields')
  end

  private

  def slot_params
    params.require(:slot_batch).permit(:agenda_id, :appointment_type_id, :date, :available,
                                       :starting_time, :capacity, :duration, :interval, :start_time, :end_time,
                                       starting_times: [],
                                       intervals: [], start_times: [], end_times: [])
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def batch_create(params, slot_params)
    unless valid_time?(params)
      render json: { error: 'At least one of starting_times or intervals is required' },
             status: :bad_request
    end

    starting_times = params.require(:starting_times).each_slice(2).to_a if params[:starting_times].present?
    interval_times = generate_times_from_intervals(params) if valid_interval?(params)
    times = [*starting_times, *interval_times&.flatten(1)].compact.uniq

    dates = slot_params.require(:date).split(', ').map(&:to_date)
    slots_data = dates.map { |date| times.map { |time| build_slot(slot_params, date, time) } }
    Slot.create(slots_data) unless slots_data.empty?
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity

  def generate_times_from_intervals(params)
    start_times = params.require(:start_times).each_slice(2).to_a
    end_times = params.require(:end_times).each_slice(2).to_a
    intervals = params.require(:intervals).each_slice(2).to_a

    start_times.map.with_index do |start_time, idx|
      end_time = end_times[idx] if end_times[idx].present?
      interval = intervals[idx] if intervals[idx].present?
      generate_times(start_time, end_time, interval) if start_time.present? && interval.present? && end_time.present?
    end
  end

  def generate_times(start_time, end_time, interval)
    start_time = Time.zone.parse("#{start_time[0]}:#{start_time[1]}")
    end_time = Time.zone.parse("#{end_time[0]}:#{end_time[1]}")
    raise ArgumentError, 'Start time must be before end time' if start_time > end_time

    interval_minutes = interval.first.to_i.minutes
    result = []

    current_time = start_time
    while current_time <= end_time
      result << [current_time.hour.to_s.rjust(2, '0'), current_time.min.to_s.rjust(2, '0')]
      current_time += interval_minutes
    end
    result
  end
  # rubocop:enable Metrics/AbcSize

  def valid_time?(params)
    return true if params[:starting_times].present?
    return true if valid_interval?(params)

    false
  end

  def valid_interval?(params)
    params[:start_times].present? &&
      params[:end_times].present? &&
      params[:intervals].present?
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

  def authorize_batch_create(params)
    authorize Slot, :new?
    return unless params[:agenda_id].present?

    @agenda = Agenda.find(params[:agenda_id])
    authorize @agenda, :can_create_slot_inside?
  end
end
