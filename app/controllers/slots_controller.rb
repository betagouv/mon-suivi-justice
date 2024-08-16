class SlotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_query_params, only: :index

  # rubocop:disable Metrics/AbcSize
  def index
    @q = policy_scope(Slot).future.with_appointment_type_with_slot_system.ransack(params[:q])
    all_slots = @q.result(distinct: true)
                  .order(:date, :starting_time)
                  .includes(:appointment_type, agenda: :place)
                  .joins(agenda: [:place])

    @slots = all_slots.page(params[:page]).per(25)
    @agendas = all_slots.map(&:agenda).uniq
    @places = @agendas.map(&:place).uniq
    @appointment_types = all_slots.map(&:appointment_type).uniq

    authorize @slots
  end
  # rubocop:enable Metrics/AbcSize

  def edit
    @slot = Slot.find(params[:id])
    authorize @slot
  end

  def update
    @slot = Slot.find(params[:id])
    authorize @slot

    if @slot.update(slot_params)
      check_if_slot_should_be_closed
      redirect_to slots_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def slot_params
    params.require(:slot).permit(:agenda_id, :appointment_type_id,
                                 :date, :starting_time, :available, :capacity, :duration)
  end

  def check_if_slot_should_be_closed
    return if @slot.full == @slot.all_capacity_used?

    @slot.update(full: @slot.all_capacity_used?) if @slot.full != @slot.all_capacity_used?
  end

  def set_query_params
    params[:q] ||= {}
    params[:q][:full_eq] = params[:q][:full_eq] == '1' ? nil : '0'
  end
end
