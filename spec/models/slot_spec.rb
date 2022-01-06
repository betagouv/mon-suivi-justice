require 'rails_helper'

RSpec.describe Slot, type: :model do
  it { should belong_to(:slot_type).optional(true) }
  it { should belong_to(:appointment_type) }
  it { should have_many(:appointments) }

  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:starting_time) }
  it { should validate_presence_of(:capacity) }
  it { should validate_presence_of(:duration) }

  describe '.relevant_and_available' do
    it 'returns available slots for an agenda and an appointment_type' do
      place1 = create(:place)
      place2 = create(:place)

      agenda1 = create(:agenda, place: place1)
      agenda2 = create(:agenda, place: place2)

      apt_type1 = create(:appointment_type)
      apt_type2 = create(:appointment_type)

      slot1 = create(:slot, agenda: agenda1,
                            appointment_type: apt_type1,
                            available: true)

      slot2 = create(:slot, agenda: agenda1,
                            appointment_type: apt_type1,
                            available: false)

      slot3 = create(:slot, agenda: agenda2,
                            appointment_type: apt_type1,
                            available: true)

      slot4 = create(:slot, agenda: agenda1,
                            appointment_type: apt_type2,
                            available: true)

      expect(Slot.relevant_and_available(agenda1, apt_type1)).to include(slot1)
      expect(Slot.relevant_and_available(agenda1, apt_type1)).not_to include(slot2)
      expect(Slot.relevant_and_available(agenda1, apt_type1)).not_to include(slot3)
      expect(Slot.relevant_and_available(agenda1, apt_type1)).not_to include(slot4)
    end
  end

  describe 'capacity' do
    it 'allows multiple appointments for a slot' do
      appointment_type = create(:appointment_type, :with_notification_types)
      slot = create(:slot, available: true, capacity: 3, used_capacity: 0, appointment_type: appointment_type)
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

  describe '.in_department' do
    it 'returns slots scoped by department' do
      department1 = create :department, number: '01', name: 'Ain'

      organization1 = create :organization
      create :areas_organizations_mapping, organization: organization1, area: department1
      place1 = create :place, organization: organization1
      agenda1 = create :agenda, place: place1
      slot1 = create :slot, agenda: agenda1

      organization2 = create :organization
      create :areas_organizations_mapping, organization: organization2, area: department1
      place2 = create :place, organization: organization2
      agenda2 = create :agenda, place: place2
      slot2 = create :slot, agenda: agenda2

      department2 = create :department, number: '02', name: 'Aisne'

      organization3 = create :organization
      create :areas_organizations_mapping, organization: organization3, area: department2
      place3 = create :place, organization: organization3
      agenda3 = create :agenda, place: place3
      create :slot, agenda: agenda3

      expect(Slot.in_department(department1)).to eq [slot1, slot2]
    end
  end

  describe '.batch_delete' do
    it 'deletes batch of slots' do
      agenda = create(:agenda)
      apt_type = create(:appointment_type)

      create(:slot, agenda: agenda, appointment_type: apt_type, date: '06/06/2021', starting_time: new_time_for(13, 0))
      create(:slot, agenda: agenda, appointment_type: apt_type, date: '06/06/2021', starting_time: new_time_for(14, 0))
      create(:slot, agenda: agenda, appointment_type: apt_type, date: '06/06/2021', starting_time: new_time_for(15, 0))
      create(:slot, agenda: agenda, appointment_type: apt_type, date: '06/06/2021', starting_time: new_time_for(16, 0))

      create(:slot, agenda: agenda, appointment_type: apt_type, date: '08/06/2021', starting_time: new_time_for(14, 0))
      create(:slot, agenda: agenda, appointment_type: apt_type, date: '08/06/2021', starting_time: new_time_for(15, 0))

      input = [{ date: '06/06/2021', starting_times: ['13:00'] }]

      expect do
        Slot.batch_delete(agenda_id: agenda.id, appointment_type_id: apt_type.id, data: input)
      end.to change { Slot.count }.by(-1)

      input2 = [{ date: '06/06/2021', starting_times: ['14:00', '15:00'] }]

      expect do
        Slot.batch_delete(agenda_id: agenda.id, appointment_type_id: apt_type.id, data: input2)
      end.to change { Slot.count }.by(-2)

      input3 = [
        { date: '06/06/2021', starting_times: ['16:00'] },
        { date: '08/06/2021', starting_times: ['14:00', '15:00'] }
      ]

      expect do
        Slot.batch_delete(agenda_id: agenda.id, appointment_type_id: apt_type.id, data: input3)
      end.to change { Slot.count }.by(-3)
    end
  end
end
