require 'rails_helper'

RSpec.describe SlotType, type: :model do
  it { should belong_to(:appointment_type) }
  it { should belong_to(:agenda) }
  it { should validate_presence_of(:week_day) }
  it { should validate_presence_of(:starting_time) }
  it { should validate_presence_of(:duration) }
  it { should validate_presence_of(:capacity) }
  it {
    should validate_uniqueness_of(:starting_time).scoped_to(%i[agenda_id appointment_type_id
                                                               week_day])
                                                  .with_message('Un créneau récurrent similaire existe déjà.')
  }

  it { should define_enum_for(:week_day).with_values(%i[monday tuesday wednesday thursday friday]) }

  describe 'Associations' do
    it 'destroys his associated not-booked slots' do
      slot_type = create :slot_type
      create :slot, slot_type: slot_type
      create :slot
      expect { slot_type.destroy }.to change(Slot, :count).from(2).to(1)
    end

    it 'does not destroys his associated booked slots' do
      slot_type = create :slot_type
      create :appointment, slot: create(:slot, slot_type: slot_type)
      create :slot
      expect { slot_type.destroy }.not_to change(Slot, :count)
    end
  end
end
