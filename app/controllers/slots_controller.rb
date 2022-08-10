class SlotsController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = policy_scope(Slot).future.with_appointment_type_with_slot_system.ransack(params[:q])
    @slots = @q.result(distinct: true)
               .order(:date, :starting_time)
               .includes(agenda: [:place])
               .joins(agenda: [:place])
               .page(params[:page]).per(25)

    authorize @slots
  end

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
      render :edit
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
end
