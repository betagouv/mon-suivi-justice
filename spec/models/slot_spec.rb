require 'rails_helper'

RSpec.describe Slot, type: :model do
  it { should belong_to(:place) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:starting_time) }

  describe '.available_for_place' do
    it 'includes available slots for a place' do
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
end
