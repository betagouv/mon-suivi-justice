require 'rails_helper'

RSpec.describe SlotFactory do
  let(:frozen_time) { Time.zone.parse '2021-07-12' }

  let(:next_tuesday) { 1.day.since }
  let(:next_wednesday) { 2.days.since }
  let(:next_thursday) { 3.days.since }

  let!(:appointment_type) { create :appointment_type }
  let!(:place) { create :place }
  let!(:place_appointment_type) { create :place_appointment_type, place:, appointment_type: }
  let!(:agenda) { create :agenda, place: }

  before do
    allow(Time).to receive(:now).and_return frozen_time
  end

  describe '#perform' do
    it 'creates only tuesday and thursday slot' do
      # because wednesday is a holiday, tuesday 13, wednesday 14, thursday 15 july
      tuesday_slot_type = create :slot_type, agenda:, appointment_type:,
                                             week_day: 'tuesday',
                                             starting_time: Time.zone.parse('2021-01-01 10:00:00')

      wednesday_slot_type = create :slot_type, agenda:, appointment_type:,
                                               week_day: 'wednesday',
                                               starting_time: Time.zone.parse('2021-01-01 09:00:00')

      thursday_slot_type = create :slot_type, agenda:, appointment_type:,
                                              week_day: 'thursday',
                                              starting_time: Time.zone.parse('2021-01-01 15:00:00')

      expect do
        SlotFactory.perform(start_date: next_tuesday, end_date: next_thursday)
      end.to change(Slot, :count).from(0).to 2

      expect(
        Slot.find_by(
          slot_type: tuesday_slot_type, agenda:, appointment_type:,
          starting_time: Time.zone.parse('2021-01-01 10:00:00'), date: next_tuesday
        )
      ).not_to be nil

      expect(
        Slot.find_by(
          slot_type: thursday_slot_type, agenda:, appointment_type:,
          starting_time: Time.zone.parse('2021-01-01 15:00:00'), date: next_thursday
        )
      ).not_to be nil

      expect(
        Slot.find_by(
          slot_type: wednesday_slot_type, agenda:, appointment_type:,
          starting_time: Time.zone.parse('2021-01-01 09:00:00'), date: next_wednesday
        )
      ).to be nil
    end

    it 'creates slots only once with multiple perform' do
      create :slot_type, agenda:, appointment_type:,
                         week_day: 'tuesday',
                         starting_time: Time.zone.parse('2021-01-01 10:00:00')

      create :slot_type, agenda:, appointment_type:,
                         week_day: 'tuesday',
                         starting_time: Time.zone.parse('2021-01-01 10:15:00')

      create :slot_type, agenda:, appointment_type:,
                         week_day: 'tuesday',
                         starting_time: Time.zone.parse('2021-01-01 10:30:00')

      create :slot_type, agenda:, appointment_type:,
                         week_day: 'tuesday',
                         starting_time: Time.zone.parse('2021-01-01 10:45:00')

      create :slot_type, agenda:, appointment_type:,
                         week_day: 'tuesday',
                         starting_time: Time.zone.parse('2021-01-01 11:00:00')

      SlotFactory.perform(start_date: next_tuesday, end_date: next_thursday)
      SlotFactory.perform(start_date: next_tuesday, end_date: next_thursday)

      result = Slot.where(agenda:, appointment_type:, date: next_tuesday)
      expect(result.count).to eq(5)
    end
  end
end
