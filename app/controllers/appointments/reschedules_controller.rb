module Appointments
  class ReschedulesController < AppointmentsController
    before_action :authenticate_user!

    def create
      old_appointment = Appointment.find_by id: params.dig(:appointment, :old_appointment_id)
      new_appointment = Appointment.new appointment_params
      authorize new_appointment

      if new_appointment.save
        cancel_old_appointment old_appointment, new_appointment
        book_new_appointment new_appointment
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

    private

    def cancel_old_appointment(old_appointment, new_appointment)
      old_appointment.cancel! send_notification: false
      HistoryItem.where(appointment: old_appointment).update_all(appointment_id: new_appointment.id)
    end

    def book_new_appointment(appointment)
      appointment.book send_notification: false
      appointment.reschedule_notif.send_now
    end
  end
end
