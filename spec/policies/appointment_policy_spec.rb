require 'rails_helper'

describe AppointmentPolicy do
  subject { AppointmentPolicy.new(user, appointment) }

  let(:appointment_type) { create(:appointment_type) }
  let(:slot) { create :slot, :without_validations, appointment_type: }
  let!(:appointment) { create(:appointment, slot:) }

  context 'for a canceled appointment' do
    let(:user) { build(:user, role: 'admin', organization: slot.place.organization) }
    let!(:appointment) { create(:appointment, slot:, state: 'canceled') }
    subject { AppointmentPolicy.new(user, appointment) }
    it { is_expected.not_to permit_action(:cancel) }
  end

  context 'for an admin' do
    let(:user) { build(:user, role: 'admin', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:cancel) }
    it { is_expected.to permit_action(:fulfil) }
    it { is_expected.to permit_action(:miss) }
    it { is_expected.to permit_action(:excuse) }
    it { is_expected.to permit_action(:rebook) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
  end

  context 'for an local_admin spip' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'local_admin') }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }
    let!(:appointment) { create(:appointment, slot:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:cancel) }
    it { is_expected.to permit_action(:fulfil) }
    it { is_expected.to permit_action(:miss) }
    it { is_expected.to permit_action(:excuse) }
    it { is_expected.to permit_action(:rebook) }
    it { is_expected.not_to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
  end

  context 'for an local_admin tj' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:place) { build(:place, organization:) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }
    let!(:appointment) { create(:appointment, slot:) }
    let(:user) { build(:user, role: 'local_admin', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:cancel) }
    it { is_expected.to permit_action(:fulfil) }
    it { is_expected.to permit_action(:miss) }
    it { is_expected.to permit_action(:excuse) }
    it { is_expected.to permit_action(:rebook) }
    it { is_expected.not_to permit_action(:agenda_spip) }
    it { is_expected.to permit_action(:agenda_jap) }
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, role: 'prosecutor', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a jap user' do
    let(:user) { build(:user, role: 'jap', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a court secretary' do
    let(:user) { build(:user, role: 'secretary_court', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a dir_greff_bex user' do
    let(:user) { build(:user, role: 'dir_greff_bex', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a bex user' do
    let(:user) { build(:user, role: 'bex', organization: slot.place.organization) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a greff_co user' do
    let(:user) { build(:user, role: 'greff_co') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a greff_tpe user' do
    let(:user) { build(:user, role: 'greff_tpe', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a greff_crpc user' do
    let(:user) { build(:user, role: 'greff_crpc', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a greff_ca user' do
    let(:user) { build(:user, role: 'greff_ca', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a dir_greff_sap user' do
    let(:user) { build(:user, role: 'dir_greff_sap', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a greff_sap user' do
    let(:user) { build(:user, role: 'greff_sap', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }

    context "for an appointment_type Sortie d'audience SAP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SAP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a cpip user' do
    let(:user) { build(:user, role: 'cpip', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP from another service' do
      let(:organization) { create(:organization) }
      let(:user) { build(:user, role: 'cpip', organization:) }
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to forbid_action(:fulfil) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a educator user' do
    let(:user) { build(:user, role: 'educator', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a psychologist user' do
    let(:user) { build(:user, role: 'psychologist', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a overseer user' do
    let(:user) { build(:user, role: 'overseer', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a dpip user' do
    let(:user) { build(:user, role: 'dpip', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end

  context 'for a secretary_spip user' do
    let(:user) { build(:user, role: 'secretary_spip', organization: slot.place.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type 1ère convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1ère convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:rebook) }
    end

    context 'for an appointment_type Convocation de suivi JAP' do
      let(:appointment_type) { create(:appointment_type, name: 'Convocation de suivi JAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:rebook) }
    end
  end
end
