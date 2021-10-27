
module Appointments
  class ReschedulesController < AppointmentsController
    before_action :authenticate_user!

    def create
      old_appointment = Appointment.find_by id: params.dig(:appointment, :old_appointment_id)
      new_appointment = Appointment.new appointment_params
      authorize new_appointment

      if new_appointment.save
        old_appointment.cancel! send_notification: false
        HistoryItem.where(appointment: old_appointment).update_all(appointment_id: new_appointment.id)
        new_appointment.book send_notification: false
        new_appointment.reschedule_notif.send_now
        redirect_to appointment_path new_appointment
      else
        redirect_to new_appointment_reschedule_path(old_appointment)
      end
    end

    def new
      @appointment = policy_scope(Appointment).find(params[:appointment_id])
      authorize @appointment
      @slots_by_date = Slot.future
                           .relevant_and_available(@appointment.slot.agenda, @appointment.appointment_type)
                           .order(:date)
                           .group_by(&:date)
    end
  end
end
