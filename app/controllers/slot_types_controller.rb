class SlotTypesController < ApplicationController
  before_action :authenticate_user!

  def index
    @slot_types = SlotType.all.page params[:page]
    authorize @slot_types
  end

  def new
    @slot_type = SlotType.new
    authorize @slot_type
  end

  def edit
    @slot_type = SlotType.find params[:id]
    authorize @slot_type
  end

  def update
    slot_type = SlotType.find params[:id]
    authorize slot_type

    if slot_type.update slot_type_params
      redirect_to slot_types_path
    else
      render :edit
    end
  end

  def destroy
    slot_type = SlotType.find params[:id]
    authorize slot_type

    slot_type.destroy
    redirect_to slot_types_path
  end

  def create
    slot_type = SlotType.new slot_type_params
    authorize slot_type

    slot_type.save ? redirect_to(slot_types_path) : render(:new)
  end

  private

  def slot_type_params
    params.require(:slot_type).permit(:agenda_id, :appointment_type_id, :week_day, :starting_time, :duration, :capacity)
  end
end
