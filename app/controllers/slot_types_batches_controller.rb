class SlotTypesBatchesController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  # rubocop:disable Metrics/AbcSize
  def create
    @agenda = Agenda.find(params[:agenda_id])
    @appointment_type = AppointmentType.find_by(id: params[:appointment_type_id])
    data = slot_types_batch_params.to_h

    if data[:interval].to_i.zero?
      flash[:error] = I18n.t('activerecord.errors.models.slot_type.batch_zero_interval')
    else
      success = SlotTypeFactory.perform(appointment_type: @appointment_type, agenda: @agenda,
                                        timezone: @current_time_zone, data:)
      flash[:error] = I18n.t('activerecord.errors.models.slot_type.batch_multiple_uniqueness') unless success
    end

    redirect_back(fallback_location: root_path)
  end

  # rubocop:enable Metrics/AbcSize
  def destroy
    conditions = { agenda_id: params[:agenda_id] }
    conditions[:week_day] = params[:weekday] if params.key?(:weekday)

    slot_types = SlotType.where(conditions)

    authorize slot_types, :destroy_all?

    slot_types.destroy_all

    redirect_back(fallback_location: root_path)
  end

  private

  def slot_types_batch_params
    params.require(:slot_types_batch).permit(:day_monday, :day_tuesday, :day_wednesday, :day_thursday,
                                             :day_friday, :first_slot, :last_slot, :interval, :capacity, :duration)
  end
end
