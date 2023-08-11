# lib/tasks/appointments.rake
namespace :appointments do
  desc "Update state of Appointments from 'created' to 'booked'"
  task update_state: :environment do
    # Retrieve all 'created' appointments
    created_appointments = Appointment.where(state: 'created').where('created_at >= ?', Date.today).includes(:slot)

    created_appointments.each do |appointment|
      # Check for a 'booked' appointment with the same convict_id, slot date, and starting time
      conflicting_appointment = Appointment.joins(:slot)
                                           .where(convict_id: appointment.convict_id,
                                                  state: 'booked',
                                                  slots: { date: appointment.slot.date,
                                                           starting_time: appointment.slot.starting_time })
                                           .first

      if conflicting_appointment
        # If conflicting appointment found, delete the 'created' appointment
        puts "Appointment #{appointment.id} will be destroyed because it is conflicting with appointment #{conflicting_appointment.id}"
        appointment.destroy
      else
        # If no conflicting appointment found, change the state
        puts "Appointment #{appointment.id} will be booked"
        appointment.book(send_notification: true)
      end
    end
  end
end
