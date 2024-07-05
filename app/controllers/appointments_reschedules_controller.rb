class AppointmentsReschedulesController < AppointmentsController
  before_action :authenticate_user!

  # rubocop:disable Metrics/AbcSize
  def create
    old_appointment = Appointment.find_by id: params.dig(:appointment, :old_appointment_id)
    new_appointment = Appointment.new appointment_params
    new_appointment.inviter_user = current_user
    authorize new_appointment, policy_class: AppointmentsReschedulesPolicy
    new_appointment.send_sms = false
    if new_appointment.save
      cancel_old_appointment old_appointment, new_appointment
      book_new_appointment new_appointment

      redirect_to appointment_path new_appointment
    else
      redirect_to new_appointment_reschedule_path(old_appointment),
                  alert: new_appointment.errors.messages.values.join(', ')
    end
  end
  # rubocop:enable Metrics/AbcSize

  def new
    @appointment = Appointment.find(params[:appointment_id])
    @appointment_type = @appointment.slot.appointment_type
    authorize @appointment, policy_class: AppointmentsReschedulesPolicy

    @slots_by_date = Slot.future
                         .relevant_and_available(@appointment.slot.agenda, @appointment.slot.appointment_type)
                         .order(:date)
                         .group_by(&:date)
  end

  private

  def cancel_old_appointment(old_appointment, new_appointment)
    old_appointment.cancel! send_notification: false
    HistoryItem.where(appointment: old_appointment).update_all(appointment_id: new_appointment.id)
  end

  def book_new_appointment(appointment)
    HistoryItem.order(created_at: :desc).where(
      appointment:, event: 'cancel_reminder_notification'
    ).first&.destroy
    HistoryItem.order(created_at: :desc).where(appointment:, event: 'cancel_appointment').first&.destroy
    HistoryItemFactory.perform(appointment:, event: :reschedule_appointment, category: 'appointment')
    appointment.book send_notification: false
    appointment.reschedule_notif.program_now if appointment.convict.phone.present?
  end
end
