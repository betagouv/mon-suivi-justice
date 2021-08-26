class CreateHistoryItemsForLegacyAppointments < ActiveRecord::Migration[6.1]
  #
  # One shot migration to create HistoryItems for old appointments
  #
  def up
    Appointment.all.each do |apt|
      next if HistoryItem.where(appointment: apt).count != 0

      HistoryItem.create!(
        convict: apt.convict,
        appointment: apt,
        event: :book_appointment
      )
    end

    Appointment.where(state: :canceled).each do |apt|
      next if HistoryItem.where(appointment: apt, event: :miss_appointment).count != 0

      HistoryItem.create!(
        convict: apt.convict,
        appointment: apt,
        event: :miss_appointment
      )
    end
  end

  def down
  end
end
