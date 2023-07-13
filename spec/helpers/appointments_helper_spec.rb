require 'rails_helper'

describe AppointmentsHelper do
  describe 'appointment_types_for_user' do
    it 'returns right appointments for jap user' do
      user = build(:user, role: :jap)
      appointment_type1 = create(:appointment_type, name: "Sortie d'audience SAP")
      appointment_type2 = create(:appointment_type, name: '1ère convocation de suivi SPIP')

      result = appointment_types_for_user(user)

      expect(user.work_at_sap?).to eq(true)
      expect(result).to include(appointment_type1)
      expect(result).not_to include(appointment_type2)
    end

    it 'returns right appointments for bex user' do
      user = build(:user, role: :bex)
      appointment_type1 = create(:appointment_type, name: "Sortie d'audience SAP")
      appointment_type2 = create(:appointment_type, name: '1ère convocation de suivi SPIP')

      result = appointment_types_for_user(user)
      expect(result).to include(appointment_type1)
      expect(result).not_to include(appointment_type2)
    end

    it 'returns right appointments for cpip user' do
      user = build(:user, role: :cpip)
      appointment_type1 = create(:appointment_type, name: "Sortie d'audience SAP")
      appointment_type2 = create(:appointment_type, name: '1ère convocation de suivi SPIP')

      result = appointment_types_for_user(user)
      expect(result).not_to include(appointment_type1)
      expect(result).to include(appointment_type2)
    end

    it 'returns right appointments for local_admin user from SPIP' do
      organization = build(:organization, organization_type: 'spip')
      user = build(:user, role: :local_admin, organization: organization)
      appointment_type1 = create(:appointment_type, name: "Sortie d'audience SPIP")
      appointment_type2 = create(:appointment_type, name: "Sortie d'audience SAP")

      result = appointment_types_for_user(user)
      expect(result).to include(appointment_type1)
      expect(result).not_to include(appointment_type2)
    end

    it 'returns right appointments for local_admin user from TJ' do
      organization = build(:organization, organization_type: 'tj')
      user = build(:user, role: :local_admin, organization: organization)
      appointment_type1 = create(:appointment_type, name: "Sortie d'audience SPIP")
      appointment_type2 = create(:appointment_type, name: "Sortie d'audience SAP")

      result = appointment_types_for_user(user)
      expect(result).to include(appointment_type1)
      expect(result).to include(appointment_type2)
    end
  end
end
