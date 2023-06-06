require 'rails_helper'

RSpec.describe Slot, type: :model do
  subject { build(:slot) }

  it { should belong_to(:slot_type).optional(true) }
  it { should belong_to(:appointment_type) }
  it { should have_many(:appointments) }

  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:starting_time) }
  it { should validate_presence_of(:capacity) }
  it { should validate_presence_of(:duration) }

  describe 'validations' do
    describe 'workday' do
      let(:place) { create(:place) }
      let(:agenda) { create(:agenda, place: place) }
      let(:apt_type) { create(:appointment_type) }

      it 'is not valid if date is a holiday' do
        slot = build(:slot, agenda: agenda, appointment_type: apt_type,
                            date: Date.civil(Date.today.year + 1, 7, 14))

        expect(slot).to_not be_valid
        expect(slot.errors.messages[:date]).to eq ["Le jour sélectionné n'est pas un jour ouvrable"]
      end

      it 'is not valid if date is a weekend' do
        slot = build(:slot, agenda: agenda, appointment_type: apt_type,
                            date: Date.today.next_occurring(:saturday))

        expect(slot).to_not be_valid
        expect(slot.errors.messages[:date]).to eq ["Le jour sélectionné n'est pas un jour ouvrable"]
      end

      it 'it is valid if date is not a weekend nor a holiday' do
        slot = build(:slot, agenda: agenda, appointment_type: apt_type,
                            date: Date.civil(2022, 5, 31))

        expect(slot).to be_valid
      end
    end

    describe 'coherent_organization_type' do
      let(:organization) { create(:organization, organization_type: :tj) }
      let(:place) { create(:place, organization: organization) }
      let(:agenda) { create(:agenda, place: place) }

      it 'is valid if organization has right type' do
        apt_type = create(:appointment_type, name: "Sortie d'audience SAP")
        slot = build(:slot, agenda: agenda, appointment_type: apt_type)

        expect(slot).to be_valid
      end

      it 'is not valid if organization has wrong type' do
        apt_type = create(:appointment_type, name: "Sortie d'audience SPIP")
        slot = build(:slot, agenda: agenda, appointment_type: apt_type)

        expect(slot).to_not be_valid
        expect(slot.errors.messages[:appointment_type]).to eq ["Ce type de rdv n'est pas possible dans ce lieu"]
      end
    end

    describe 'place transfert validation' do
      describe 'tranfert out' do
        let(:agenda) { create(:agenda) }
        let(:place) { create(:place, agendas: [agenda]) }
        it 'is not valid if slot after transfert' do
          create(:place_transfert, old_place: place, date: Date.yesterday)
          slot = build(:slot, agenda: place.agendas.first, date: Date.today)

          expect(slot).to_not be_valid
        end
        it 'is valid if slot before transfert' do
          create(:place_transfert, old_place: place, date: Date.tomorrow)
          slot = build(:slot, agenda: place.agendas.first, date: Date.today)

          expect(slot).to be_valid
        end
      end
      describe 'tranfert in' do
        let(:agenda) { create(:agenda) }
        let(:place) { create(:place, agendas: [agenda]) }
        it 'is not valid if slot before transfert' do
          create(:place_transfert, new_place: place, date: Date.tomorrow)
          slot = build(:slot, agenda: place.agendas.first, date: Date.today)

          expect(slot).to_not be_valid
        end
        it 'is valid if slot after transfert' do
          create(:place_transfert, new_place: place, date: Date.yesterday)
          slot = build(:slot, agenda: place.agendas.first, date: Date.today)

          expect(slot).to be_valid
        end
      end
    end
  end

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
      expect(slot.full).to eq(false)

      create(:appointment, slot: slot).book
      create(:appointment, slot: slot).book

      slot.reload
      expect(slot.used_capacity).to eq(3)
      expect(slot.full).to eq(true)
    end
  end

  describe '.in_departments' do
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

      expect(Slot.in_departments(organization1.departments)).to eq [slot1, slot2]
    end
  end
end
