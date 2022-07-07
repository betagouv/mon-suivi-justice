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

  def new
    @slot = Slot.new
    authorize @slot
  end

  def create
    @slot = Slot.new(slot_params)
    authorize @slot

    if @slot.save
      redirect_to slots_path
    else
      render :new
    end
  end

  def edit
    @slot = Slot.find(params[:id])
    authorize @slot
  end

  def update
    @slot = Slot.find(params[:id])
    authorize @slot

    if @slot.update(slot_params)
      flash[:notice] = "la capacité du créneau a été modifiée"
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
end
