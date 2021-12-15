class SlotTypesBatchesController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def create
    @agenda = Agenda.find params[:agenda_id]
    @appointment_type = AppointmentType.find_by(id: params[:appointment_type_id])
    @appointment_type ||= @agenda.place.appointment_types.first

    SlotTypeFactory.perform(appointment_type: @appointment_type, agenda: @agenda, data: slot_types_batch_params.to_h)

    redirect_back(fallback_location: root_path)
  end

  def destroy
    slot_types = SlotType.where(agenda_id: params[:agenda_id])
    slot_types.destroy_all

    redirect_back(fallback_location: root_path)
  end

  private

  def slot_types_batch_params
    params.require(:slot_types_batch).permit(:day_monday, :day_tuesday, :day_wednesday, :day_thursday,
                                             :day_friday, :first_slot, :last_slot, :interval, :capacity, :duration)
  end
end
