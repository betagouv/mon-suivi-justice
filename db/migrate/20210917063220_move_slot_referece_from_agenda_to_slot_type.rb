class MoveSlotRefereceFromAgendaToSlotType < ActiveRecord::Migration[6.1]
  def change
    add_reference :slots, :slot_type, foreign_key: true, index: true
    add_reference :slot_types, :agenda, foreign_key: true, index: true


    if defined?(Slot) && defined?(SlotType)
      # # We destroy all 'not-yet-booked- slots'
      Slot.where.not(id: Appointment.select(:slot_id)).destroy_all

      SlotType.find_each do |slot_type|
        Agenda.find_each do |agenda|
          SlotType.create(
            week_day: slot_type.week_day, starting_time: slot_type.starting_time, duration: slot_type.duration,
            capacity: slot_type.capacity, appointment_type: slot_type.appointment_type, agenda: agenda
          )
          slot_type.destroy # destroy the legacy slot type without agenda
        end
      end

      # Link remaining booked slot to their new corresponding slot_type (agenda reference is to be removed later on)
      Slot.where(id: Appointment.select(:slot_id)).find_each do |slot|
        next if SlotType.week_days.keys.exclude?(slot.date.strftime('%A').downcase)

        slot_type = SlotType.find_by(
          agenda: slot.agenda, appointment_type: slot.appointment_type, starting_time: slot.starting_time, week_day: slot.date.strftime('%A').downcase
        )
        slot.update slot_type: slot_type
      end

      Slot.where(slot_type: nil).destroy_all # Just in case some old slots not booked are still hanging around
    end
  end
end
