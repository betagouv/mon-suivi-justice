class SlotsBatchesController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def new; end

  def create
    result = batch_create(params, slot_params)

    if result.all?(&:persisted?)
      flash.discard
      redirect_to slots_path
    else
      flash[:alert] = I18n.t('slots.failed_batch_creation')
      render :new
    end
  end

  def update
    slots = Slot.where(id: params[:slot_ids])
    slots.update_all(available: false)

    redirect_back(fallback_location: root_path)

    authorize slots
  end

  def display_time_fields; end

  private

  def slot_params
    params.require(:slot_batch).permit(:agenda_id, :appointment_type_id, :date, :available,
                                       :starting_time, :capacity, :duration, starting_times: [])
  end

  def batch_create(params, slot_params)
    times = params.require(:starting_times).each_slice(2).to_a
    slots_data = []

    times.each { |time| slots_data << build_slot(slot_params, time) }

    Slot.create(slots_data)
  end

  def build_slot(params, time)
    {
      agenda_id: params[:agenda_id],
      appointment_type_id: params[:appointment_type_id],
      date: params[:date],
      starting_time: Time.new(2021, 6, 21, time[0], time[1], 0, current_time_zone),
      capacity: params[:capacity],
      duration: params[:duration]
    }
  end
end
