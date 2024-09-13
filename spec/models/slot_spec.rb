require 'rails_helper'

RSpec.describe Slot, type: :model do
  include ApplicationHelper
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
      let(:agenda) { create(:agenda, place:) }
      let(:apt_type) { create(:appointment_type) }

      it 'is not valid if date is a holiday' do
        slot = build(:slot, agenda:, appointment_type: apt_type,
                            date: Date.civil(Date.today.year + 1, 7, 14))

        expect(slot).to_not be_valid
        expect(slot.errors.messages[:date]).to eq ["Le jour sélectionné n'est pas un jour ouvrable"]
      end

      it 'is not valid if date is a weekend' do
        slot = build(:slot, agenda:, appointment_type: apt_type,
                            date: Date.today.next_occurring(:saturday))

        expect(slot).to_not be_valid
        expect(slot.errors.messages[:date]).to eq ["Le jour sélectionné n'est pas un jour ouvrable"]
      end

      it 'it is valid if date is not a weekend nor a holiday' do
        slot = build(:slot, agenda:, appointment_type: apt_type,
                            date: Date.civil(2022, 5, 31))

        expect(slot).to be_valid
      end
    end

    describe 'coherent_organization_type' do
      let(:organization) { create(:organization, organization_type: :tj) }
      let(:place) { create(:place, organization:) }
      let(:agenda) { create(:agenda, place:) }

      it 'is valid if organization has right type' do
        apt_type = create(:appointment_type, name: "Sortie d'audience SAP")
        slot = build(:slot, agenda:, appointment_type: apt_type)

        expect(slot).to be_valid
      end

      it 'is not valid if organization has wrong type' do
        apt_type = create(:appointment_type, name: "Sortie d'audience SPIP")
        slot = build(:slot, agenda:, appointment_type: apt_type)

        expect(slot).to_not be_valid
        expect(slot.errors.messages[:appointment_type]).to eq ["Ce type de convocation n'est pas possible dans ce lieu"]
      end
    end

    describe 'place transfert validation' do
      describe 'tranfert out' do
        let(:agenda) { create(:agenda) }
        let(:place) { create(:place, agendas: [agenda]) }
        it 'is not valid if slot after transfert' do
          transfert_date = next_valid_day(date: Date.today)
          after_transfert_date = next_valid_day(date: transfert_date, day: :monday)
          create(:place_transfert, old_place: place, date: transfert_date)
          slot = build(:slot, agenda: place.agendas.first, date: after_transfert_date)

          expect(slot).to_not be_valid
        end
        it 'is valid if slot before transfert' do
          slot_date = next_valid_day(day: :monday)
          transfert_date = next_valid_day(date: slot_date)
          create(:place_transfert, old_place: place, date: transfert_date)
          slot = build(:slot, agenda: place.agendas.first, date: slot_date)

          expect(slot).to be_valid
        end

        it 'should not crash with empty slot date' do
          create(:place_transfert, old_place: place, date: Date.tomorrow)
          slot = build(:slot, agenda: place.agendas.first, date: '')

          expect(slot).to be_invalid
        end
      end
      describe 'tranfert in' do
        let(:agenda) { create(:agenda) }
        let(:place) { create(:place, agendas: [agenda]) }
        it 'is not valid if slot before transfert' do
          slot_date = next_valid_day(day: :monday)
          transfert_date = next_valid_day(date: slot_date)
          create(:place_transfert, new_place: place, date: transfert_date)
          slot = build(:slot, agenda: place.agendas.first, date: slot_date)

          expect(slot).to_not be_valid
        end
        it 'is valid if slot after transfert' do
          transfert_date = next_valid_day(date: Date.today)
          after_transfert_date = next_valid_day(date: transfert_date, day: :monday)
          create(:place_transfert, new_place: place, date: transfert_date)
          slot = build(:slot, agenda: place.agendas.first, date: after_transfert_date)

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
      appointment_type = create(:appointment_type, :with_notification_types, organization: create(:organization))
      slot = create(:slot, available: true, capacity: 3, used_capacity: 0, appointment_type:)
      appointment = create(:appointment, slot:)

      p appointment.appointment_type.notification_types.where(organization: appointment.organization, role: :reminder)
      appointment.book
      slot.reload
      expect(slot.used_capacity).to eq(1)
      expect(slot.full).to eq(false)

      create(:appointment, slot:).book
      create(:appointment, slot:).book

      slot.reload
      expect(slot.used_capacity).to eq(3)
      expect(slot.full).to eq(true)
    end
  end

  describe '.available_or_with_appointments' do
    let(:date) { next_valid_day(date: Date.today) }
    let(:appointment_type) { create(:appointment_type) }

    let!(:available_slot) { create(:slot, date:, appointment_type:, available: true) }
    let!(:booked_slot) { create(:slot, date:, appointment_type:, available: false) }
    let!(:slot_without_appointment) { create(:slot, date:, appointment_type:, available: true) }
    let!(:slot_unavailable_without_appointment) do
      create(:slot, date:, appointment_type:, available: false)
    end

    let!(:appointment) { create(:appointment, slot: booked_slot) }

    it 'returns slots with appointments or available slots for the given date and appointment type' do
      slots = described_class.available_or_with_appointments(date, appointment_type)

      expect(slots).to include(available_slot)
      expect(slots).to include(booked_slot)
      expect(slots).to include(slot_without_appointment)
      expect(slots).not_to include(slot_unavailable_without_appointment)
    end
  end

  describe 'used_capacity' do
    it 'cant be negative' do
      appointment_type = create(:appointment_type, :with_notification_types, organization: create(:organization))
      slot = create(:slot, available: true, capacity: 3, used_capacity: 0, appointment_type:)

      expect(slot.decrement(:used_capacity)).not_to be_valid
    end
  end
end
