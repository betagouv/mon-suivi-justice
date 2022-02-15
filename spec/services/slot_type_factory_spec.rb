require 'rails_helper'

RSpec.describe SlotTypeFactory do
  describe 'creates batches of slot_types' do
    let(:apt_type) { create :appointment_type }
    let(:place) { create :place }
    let(:agenda) { create :agenda, place: place }
    let(:place_appointment_type) { create :place_appointment_type, place: place, appointment_type: apt_type }
    let(:data) do
      {
        day_monday: '1',
        day_tuesday: '1',
        day_wednesday: '0',
        day_thursday: '0',
        day_friday: '0',
        'first_slot(4i)': '9',
        'first_slot(5i)': '00',
        'last_slot(4i)': '11',
        'last_slot(5i)': '00',
        interval: 30,
        capacity: 30,
        duration: 30
      }
    end

    context 'none of the slot_types exist' do
      it 'works' do
        expect do
          SlotTypeFactory.perform(appointment_type: apt_type, agenda: agenda, data: data)
        end.to change(SlotType, :count).by(10)
      end

      it 'returns true' do
        expect(SlotTypeFactory.perform(appointment_type: apt_type, agenda: agenda, data: data)).to eq(true)
      end
    end

    context 'one of the slot_type already exists' do
      before do
        create(:slot_type, agenda: agenda, appointment_type: apt_type, week_day: 'monday', starting_time: '10:00')
      end

      it 'returns false' do
        expect(SlotTypeFactory.perform(appointment_type: apt_type, agenda: agenda, data: data)).to eq(false)
      end
    end
  end

  describe 'build_starting_times' do
    it 'creates array of starting times' do
      expected = [
        Time.new(2021, 6, 21, 9, 00, 0, '+01:00'),
        Time.new(2021, 6, 21, 9, 15, 0, '+01:00'),
        Time.new(2021, 6, 21, 9, 30, 0, '+01:00'),
        Time.new(2021, 6, 21, 9, 45, 0, '+01:00'),
        Time.new(2021, 6, 21, 10, 00, 0, '+01:00'),
        Time.new(2021, 6, 21, 10, 15, 0, '+01:00'),
        Time.new(2021, 6, 21, 10, 30, 0, '+01:00'),
        Time.new(2021, 6, 21, 10, 45, 0, '+01:00'),
        Time.new(2021, 6, 21, 11, 00, 0, '+01:00'),
        Time.new(2021, 6, 21, 11, 15, 0, '+01:00'),
        Time.new(2021, 6, 21, 11, 30, 0, '+01:00'),
        Time.new(2021, 6, 21, 11, 45, 0, '+01:00'),
        Time.new(2021, 6, 21, 12, 00, 0, '+01:00')
      ]

      result = SlotTypeFactory.build_starting_times(
        first_slot: Time.new(2021, 6, 21, 9, 00, 0, '+01:00'),
        last_slot: Time.new(2021, 6, 21, 12, 00, 0, '+01:00'),
        interval: 15
      )

      expect(result).to eq(expected)
    end
  end
end
