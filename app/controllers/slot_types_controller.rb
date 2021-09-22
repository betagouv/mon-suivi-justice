class SlotTypesController < ApplicationController
  before_action :authenticate_user!

  def update
    slot_type = SlotType.find params[:id]
    authorize slot_type

    slot_type.update slot_type_params
    redirect_to edit_place_path(slot_type.agenda.place)
  end

  def destroy
    slot_type = SlotType.find params[:id]
    authorize slot_type

    slot_type.destroy
    redirect_to edit_place_path(slot_type.agenda.place)
  end

  def create
    slot_type = SlotType.new slot_type_params
    authorize slot_type

    slot_type.save
    redirect_to edit_place_path(slot_type.agenda.place)
  end

  private

  def slot_type_params
    params.require(:slot_type).permit(:agenda_id, :appointment_type_id, :week_day, :starting_time, :duration, :capacity)
  end
end
