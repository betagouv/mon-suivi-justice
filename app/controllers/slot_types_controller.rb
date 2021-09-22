class SlotTypesController < ApplicationController
  before_action :authenticate_user!

  def index
    @agenda = Agenda.find params[:agenda_id]
    @slot_type = SlotType.new agenda: @agenda
    @slot_types = @agenda.slot_types
    authorize @slot_types
  end

  def update
    slot_type = SlotType.find params[:id]
    authorize slot_type

    slot_type.update slot_type_params
    redirect_to agenda_slot_types_path(slot_type.agenda)
  end

  def destroy
    slot_type = SlotType.find params[:id]
    authorize slot_type

    slot_type.destroy
    redirect_to agenda_slot_types_path(slot_type.agenda)
  end

  def create
    slot_type = SlotType.new slot_type_params
    authorize slot_type

    slot_type.save
    redirect_to agenda_slot_types_path(slot_type.agenda)
  end

  private

  def slot_type_params
    params.require(:slot_type).permit(:agenda_id, :appointment_type_id, :week_day, :starting_time, :duration, :capacity)
  end
end
