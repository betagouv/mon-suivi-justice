require 'rails_helper'

RSpec.describe ExtraField, type: :model do
  describe '#find_places_with_shared_appointment_types' do
    let!(:linked_organization) { create(:organization, organization_type: :spip) }
    let!(:organization) { create(:organization, organization_type: :tj, spips: [linked_organization]) }
    let!(:appointment_type) { AppointmentType.find_or_create_by!(name: "Sortie d'audience SAP") }
    let!(:linked_appointment_type) { AppointmentType.find_or_create_by!(name: "Sortie d'audience SPIP") }
    let!(:place) { create(:place, organization:, appointment_types: [appointment_type]) }
    let!(:linked_place) do
      create(:place, organization: linked_organization, appointment_types: [linked_appointment_type])
    end
    let(:extra_field_apt_types) { [appointment_type] }
    let!(:extra_field) do
      create(:extra_field, organization:, appointment_types: extra_field_apt_types, name: "date d'audience",
                           data_type: :date)
    end

    context 'when places share appointment types with the extra field' do
      it 'returns associated places from the same organization' do
        expect(extra_field.find_places_with_shared_appointment_types).to match_array([place])
      end

      it 'does not return places not sharing appointment types' do
        expect(extra_field.find_places_with_shared_appointment_types).not_to match_array([linked_place])
      end
    end

    context 'when linked organizations have places sharing appointment types' do
      let(:extra_field_apt_types) { [linked_appointment_type] }

      it 'includes places from linked organizations' do
        expect(extra_field.find_places_with_shared_appointment_types).to match_array([linked_place])
      end
    end

    context 'with no matching places' do
      let(:unmatched_appointment_type) { create(:appointment_type) }
      let(:extra_field_apt_types) { [unmatched_appointment_type] }

      it 'returns an empty array' do
        expect(extra_field.find_places_with_shared_appointment_types).to be_empty
      end
    end

    context 'with matching in orga and link_orga places' do
      let(:extra_field_apt_types) { [appointment_type, linked_appointment_type] }

      it 'returns an empty array' do
        expect(extra_field.find_places_with_shared_appointment_types).to match_array([place, linked_place])
      end
    end
  end
end
