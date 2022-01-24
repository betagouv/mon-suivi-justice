# == Schema Information
#
# Table name: slot_types
#
#  id                  :bigint           not null, primary key
#  capacity            :integer          default(1)
#  duration            :integer          default(30)
#  starting_time       :time
#  week_day            :integer          default("monday")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  agenda_id           :bigint
#  appointment_type_id :bigint
#
# Indexes
#
#  index_slot_types_on_agenda_id            (agenda_id)
#  index_slot_types_on_appointment_type_id  (appointment_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (agenda_id => agendas.id)
#  fk_rails_...  (appointment_type_id => appointment_types.id)
#
require 'rails_helper'

RSpec.describe SlotType, type: :model do
  it { should belong_to(:appointment_type) }
  it { should belong_to(:agenda) }
  it { should validate_presence_of(:week_day) }
  it { should validate_presence_of(:starting_time) }
  it { should validate_presence_of(:duration) }
  it { should validate_presence_of(:capacity) }

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
