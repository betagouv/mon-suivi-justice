require 'rails_helper'

RSpec.describe Slot, type: :model do
  it { should belong_to(:place) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:starting_time) }
  it { should validate_presence_of(:capacity) }
  it { should validate_presence_of(:duration) }

  describe '.available_for_place' do
    it 'returns available slots for a place' do
      place1 = create(:place)
      place2 = create(:place)

      slot1 = create(:slot, place: place1, available: true)
      slot2 = create(:slot, place: place1, available: false)
      slot3 = create(:slot, place: place2)

      expect(Slot.available_for_place(place1)).to include(slot1)
      expect(Slot.available_for_place(place1)).not_to include(slot2)
      expect(Slot.available_for_place(place1)).not_to include(slot3)
    end
  end

  describe 'capacity' do
    it 'allows multiple appointments for a slot' do
      slot = create(:slot, available: true, capacity: 3, used_capacity: 0)

      create(:appointment, slot: slot).book

      slot.reload
      expect(slot.used_capacity).to eq(1)
      expect(slot.available).to eq(true)

      create(:appointment, slot: slot).book
      create(:appointment, slot: slot).book

      slot.reload
      expect(slot.used_capacity).to eq(3)
      expect(slot.available).to eq(false)
    end
  end
end
