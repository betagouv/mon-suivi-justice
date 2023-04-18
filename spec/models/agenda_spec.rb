require 'rails_helper'

RSpec.describe Agenda, type: :model do
  it { should validate_presence_of(:name) }

  it { should belong_to(:place) }
  it { should have_many(:slots) }
  it { should have_many(:slot_types).dependent(:destroy) }

  describe '.in_organization' do
    before do
      @organization = create :organization
      place_in = create :place, organization: @organization
      @agenda_in = create :agenda, place: place_in
      create :agenda
    end

    it 'returns correct relation' do
      expect(Agenda.in_organization(@organization)).to eq [@agenda_in]
    end
  end

  describe '#has_appointment_type_with_slot_types?' do
    it 'works' do
      apt_type1 = create(:appointment_type, name: "Sortie d'audience SPIP")
      place1 = create(:place)
      create(:place_appointment_type, place: place1, appointment_type: apt_type1)
      agenda1 = create(:agenda, place: place1)
      create(:slot_type, appointment_type: apt_type1, agenda: agenda1)

      expect(agenda1.appointment_type_with_slot_types?).to eq true

      apt_type2 = create(:appointment_type, name: 'RDV de suivi SPIP')
      place2 = create(:place)
      create(:place_appointment_type, place: place2, appointment_type: apt_type2)
      agenda2 = create(:agenda, place: place2)
      create(:slot_type, appointment_type: apt_type2, agenda: agenda2)

      expect(agenda2.appointment_type_with_slot_types?).to eq false
    end
  end

  describe '.in_departments' do
    before do
      @department1 = create :department, number: '01', name: 'Ain'

      @orga = create :organization
      create :areas_organizations_mapping, organization: @orga, area: @department1

      place1 = create :place, organization: @orga
      @agenda1 = create :agenda, place: place1
      @agenda2 = create :agenda, place: place1
      create :agenda
    end

    it 'returns agendas for multiple departments' do
      department2 = create :department, number: '02', name: 'Aisne'
      create :areas_organizations_mapping, organization: @orga, area: department2

      expect(Agenda.in_departments(@orga.departments).to_a).to include(@agenda1, @agenda2)
    end

    it 'works if only one department is provided' do
      expect(Agenda.in_departments(@orga.departments).to_a).to include(@agenda1, @agenda2)
    end
  end

  describe '.slots_for_date' do
    it 'return available slots for a given date' do
      apt_type1 = create(:appointment_type, name: "Sortie d'audience SPIP")
      place1 = create(:place)
      create(:place_appointment_type, place: place1, appointment_type: apt_type1)
      agenda1 = create(:agenda, place: place1)
      slot_type1 = create(:slot_type, appointment_type: apt_type1, agenda: agenda1)
      slot1 = create(:slot, agenda: agenda1, date: Date.today, appointment_type: apt_type1, slot_type: slot_type1)
      slot2 = create(:slot, agenda: agenda1, date: Date.today, appointment_type: apt_type1, slot_type: slot_type1)
      expect(agenda1.slots_for_date(Date.today, apt_type1)).to match_array([slot1, slot2])
      slot1.update(available: false)
      expect(agenda1.slots_for_date(Date.today, apt_type1)).to match_array([slot2])
    end

    it 'return unavailable slots with appointment for a given date' do
      apt_type1 = create(:appointment_type, name: "Sortie d'audience SPIP")
      place1 = create(:place)
      create(:place_appointment_type, place: place1, appointment_type: apt_type1)
      agenda1 = create(:agenda, place: place1)
      slot_type1 = create(:slot_type, appointment_type: apt_type1, agenda: agenda1)
      slot1 = create(:slot, agenda: agenda1, date: Date.today, appointment_type: apt_type1, slot_type: slot_type1)
      slot2 = create(:slot, agenda: agenda1, date: Date.today, appointment_type: apt_type1, slot_type: slot_type1)
      expect(agenda1.slots_for_date(Date.today, apt_type1)).to match_array([slot1, slot2])
      create(:appointment, slot: slot1)
      slot1.update(available: false)
      expect(agenda1.slots_for_date(Date.today, apt_type1)).to match_array([slot1, slot2])
    end
  end
end
