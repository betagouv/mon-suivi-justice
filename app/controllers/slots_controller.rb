class SlotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_query_params, only: :index

  # rubocop:disable Metrics/AbcSize
  def index
    @q = policy_scope(Slot).future.with_appointment_type_with_slot_system.ransack(params[:q])
    all_slots = @q.result(distinct: true)
                  .order(:date, :starting_time)
                  .includes(agenda: [:place])
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

    used_capacity = @slot.used_capacity
    min_capacity = @slot.used_capacity.zero? ? used_capacity + 1 : used_capacity

    @hint1 = t('slots.edit_used_capacity', data: used_capacity)
    @hint2 = t('slots.edit_minimum_capacity', data: min_capacity)
    @hint3 = t('slots.edit_warning', data: used_capacity)
    @hint = "#{@hint1}<br/>#{@hint2}<br/>#{used_capacity.zero? ? '' : @hint3}".html_safe

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
    return unless @slot.all_capacity_used? == true

    @slot.update(full: true)
  end

  def set_query_params
    params[:q] ||= {}
    params[:q][:full_eq] = params[:q][:full_eq] == '1' ? nil : '0'
  end
end
