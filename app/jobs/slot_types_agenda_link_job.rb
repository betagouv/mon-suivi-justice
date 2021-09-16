class SlotTypesAgendaLinkJob < ApplicationJob
  #
  # Job to seed the Agenda<>SlotTypes relation after the migration, to be done asap after migration
  # Will duplicate each current slot type in every agenda.
  #
  def perform
    SlotType.find_each do |slot_type|
      Agenda.find_each do |agenda|
        SlotType.create(
          week_day: slot_type.week_day, starting_time: slot_type.starting_time, duration: slot_type.duration,
          capacity: slot_type.capacity, appointment_type: slot_type.appointment_type, agenda: agenda
        )
        slot_type.destroy # destroy the legacy slot type without agenda
      end
    end
    # Link booked slot to their corresponding slot_type, agenda reference will be removed later
    Slot.find_each do |slot|
      slot_type = SlotType.find_by(
        agenda: slot.agenda, appointment_type: slot.appointment_type,
        starting_time: slot.starting_time, weekday: slot.date.strftime('%A').downcase
      )
      slot.update slot_type: slot_type
    end
    # Re-launch Slot creation factory to re-seed new slot
    SlotCreationJob.perform_later oneshot: true
  end
end
