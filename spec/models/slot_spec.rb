require 'rails_helper'

RSpec.describe Slot, type: :model do
  it { should belong_to(:place) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:starting_time) }

  describe '.available_for_place' do
    it 'includes available slots for a place' do
      place_1 = create(:place)
      place_2 = create(:place)

      slot_1 = create(:slot, place: place_1, available: true)
      slot_2 = create(:slot, place: place_1, available: false)
      slot_3 = create(:slot, place: place_2)

      expect(Slot.available_for_place(place_1)).to include(slot_1)
      expect(Slot.available_for_place(place_1)).not_to include(slot_2)
      expect(Slot.available_for_place(place_1)).not_to include(slot_3)
    end
  end
end
