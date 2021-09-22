require 'rails_helper'

RSpec.describe SlotFactory do
  let(:frozen_time) { Time.zone.parse '2021-07-12' }
  # tuesday 13, wednesday 14, thursday 15 july (14 is holiday)
  let(:appointment_type) { create :appointment_type }
  let(:place) { create :place }
  let(:place_appointment_type) { create :place_appointment_type, place: place, appointment_type: appointment_type }

  let(:agenda) { create :agenda, place: place }
  let(:tuesday_slot) do
    create :slot_type, agenda: agenda, appointment_type: appointment_type, week_day: 'tuesday',
                       starting_time: Time.zone.parse('2021-01-01 10:00:00')
  end
  let(:wednesday_slot) do
    create :slot_type, agenda: agenda, appointment_type: appointment_type, week_day: 'wednesday',
                       starting_time: Time.zone.parse('2021-01-01 09:00:00')
  end
  let(:thursday_slot) do
    create :slot_type, agenda: agenda, appointment_type: appointment_type, week_day: 'thursday',
                       starting_time: Time.zone.parse('2021-01-01 15:00:00')
  end

  before do
    allow(Time).to receive(:now).and_return frozen_time
    appointment_type
    place_appointment_type
    agenda
    tuesday_slot
    wednesday_slot
    thursday_slot
  end

  describe '#Initialize' do
    it 'creates 2 new slot' do
      expect do
        SlotFactory.perform(start_date: 1.day.since, end_date: 3.days.since)
      end.to change(Slot, :count).from(0).to 2
    end
    it 'creates tuesday slot' do
      SlotFactory.perform(start_date: 1.day.since, end_date: 3.days.since)
      expect(
        Slot.find_by(
          slot_type: tuesday_slot, agenda: agenda, appointment_type: appointment_type,
          starting_time: Time.zone.parse('2021-01-01 10:00:00'),
          duration: 60, capacity: 3, available: true, date: 1.day.since
        )
      ).not_to be nil
    end
    it 'creates thursday slot' do
      SlotFactory.perform(start_date: 1.day.since, end_date: 3.days.since)
      expect(
        Slot.find_by(
          slot_type: thursday_slot, agenda: agenda, appointment_type: appointment_type,
          starting_time: Time.zone.parse('2021-01-01 15:00:00'),
          duration: 60, capacity: 3, available: true, date: 3.day.since
        )
      ).not_to be nil
    end
  end
end
