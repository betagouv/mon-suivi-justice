class SlotsController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = Slot.future.ransack(params[:q])
    @slots = @q.result(distinct: true)
               .includes(agenda: [:place])
               .joins(agenda: [:place])
               .page params[:page]

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

  def destroy
    @slot = Slot.find(params[:id])
    authorize @slot

    @slot.destroy
    redirect_to slots_path
  end

  private

  def slot_params
    params.require(:slot).permit(:agenda_id, :appointment_type_id,
                                 :date, :starting_time)
  end
end
