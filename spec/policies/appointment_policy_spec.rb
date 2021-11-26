require 'rails_helper'

describe AppointmentPolicy do
  subject { AppointmentPolicy.new(user, appointment) }

  let(:appointment_type) { create(:appointment_type) }
  let(:slot) { create :slot, appointment_type: appointment_type }
  let!(:appointment) { create(:appointment, slot: slot) }

  context 'for an admin' do
    let(:user) { build(:user, role: 'admin') }

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
    it { is_expected.to permit_action(:reschedule) }
    it { is_expected.to permit_action(:index_today) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
  end

  context 'for an local_admin' do
    let(:user) { build(:user, role: 'local_admin') }

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
    it { is_expected.to permit_action(:reschedule) }
    it { is_expected.to permit_action(:index_today) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, role: 'prosecutor') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:index_today) }
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
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a jap user' do
    let(:user) { build(:user, role: 'jap') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }
    it { is_expected.to forbid_action(:index_today) }

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
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a court secretary' do
    let(:user) { build(:user, role: 'secretary_court') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }
    it { is_expected.to forbid_action(:index_today) }

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
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a dir_greff_bex user' do
    let(:user) { build(:user, role: 'dir_greff_bex') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
    it { is_expected.to forbid_action(:index_today) }

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
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end
  end

  context 'for a bex user' do
    let(:user) { build(:user, role: 'bex') }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:index_today) }
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
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a greff_co user' do
    let(:user) { build(:user, role: 'greff_co') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:index_today) }
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
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a dir_greff_sap user' do
    let(:user) { build(:user, role: 'dir_greff_sap') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }
    it { is_expected.to forbid_action(:index_today) }

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
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a greff_sap user' do
    let(:user) { build(:user, role: 'greff_sap') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }
    it { is_expected.to forbid_action(:index_today) }

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
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a sap user' do
    let(:user) { build(:user, role: 'sap') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }
    it { is_expected.to forbid_action(:index_today) }

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
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a cpip user' do
    let(:user) { build(:user, role: 'cpip') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
    it { is_expected.to permit_action(:index_today) }

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a educator user' do
    let(:user) { build(:user, role: 'educator') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
    it { is_expected.to permit_action(:index_today) }

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a psychologist user' do
    let(:user) { build(:user, role: 'psychologist') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
    it { is_expected.to permit_action(:index_today) }

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a overseer user' do
    let(:user) { build(:user, role: 'overseer') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
    it { is_expected.to permit_action(:index_today) }

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a dpip user' do
    let(:user) { build(:user, role: 'dpip') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
    it { is_expected.to permit_action(:index_today) }

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end

  context 'for a secretary_spip user' do
    let(:user) { build(:user, role: 'secretary_spip') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
    it { is_expected.to permit_action(:index_today) }

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type 1er RDV SPIP' do
      let(:appointment_type) { create(:appointment_type, name: '1er RDV SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SPIP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SPIP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:cancel) }
      it { is_expected.to permit_action(:fulfil) }
      it { is_expected.to permit_action(:miss) }
      it { is_expected.to permit_action(:excuse) }
      it { is_expected.to permit_action(:reschedule) }
    end

    context 'for an appointment_type RDV de suivi SAP' do
      let(:appointment_type) { create(:appointment_type, name: 'RDV de suivi SAP') }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:cancel) }
      it { is_expected.to forbid_action(:fulfil) }
      it { is_expected.to forbid_action(:miss) }
      it { is_expected.to forbid_action(:excuse) }
      it { is_expected.to forbid_action(:reschedule) }
    end
  end
end
