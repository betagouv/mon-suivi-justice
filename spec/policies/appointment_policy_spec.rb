require 'rails_helper'

describe AppointmentPolicy do
  subject { AppointmentPolicy.new(user, appointment) }

  let(:appointment_type) { create(:appointment_type) }
  let(:slot) { create :slot, :without_validations, appointment_type: }
  let(:convict) { create :convict, organizations: [slot.place.organization] }
  let!(:appointment) { create(:appointment, slot:, state: :booked, creating_organization: slot.place.organization, convict:) }

  context 'related to appointment status' do
    let(:user) { build(:user, role: 'admin', organization: slot.place.organization) }

    context 'for a booked appointment' do
      let!(:appointment) { create(:appointment, slot:, state: 'booked') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to permit_action(:cancel) }
    end

    context 'for a canceled appointment' do
      let!(:appointment) { create(:appointment, slot:, state: 'canceled') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end

    context 'for a created appointment' do
      let!(:appointment) { create(:appointment, slot:, state: 'created') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end

    context 'for a fulfiled appointment' do
      let!(:appointment) { create(:appointment, slot:, state: 'fulfiled') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end

    context 'for a no_show appointment' do
      let!(:appointment) { create(:appointment, slot:, state: 'no_show') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end

    context 'for a excused appointment' do
      let!(:appointment) { create(:appointment, slot:, state: 'excused') }
      subject { AppointmentPolicy.new(user, appointment) }

      it { is_expected.to forbid_action(:cancel) }
    end
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
    let!(:appointment) { create(:appointment, slot:, state: :booked) }

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
    let(:user) { build(:user, role: 'local_admin', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }

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

    context "for an appointment_type Sortie d'audience SPIP" do
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

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
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'bex', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }

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
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

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
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'greff_co', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }

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
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

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
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'greff_tpe', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }

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
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

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
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'greff_crpc', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }

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
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

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
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'greff_co', organization:) }
    let(:place) { build(:place, organization: user.organization) }
    let(:agenda) { build :agenda, place: }
    let(:slot) { create :slot, :without_validations, appointment_type:, agenda: }

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
      let(:organization2) { build :organization, organization_type: 'spip' }
      let(:place) { build(:place, organization: organization2) }
      let(:appointment_type) { create(:appointment_type, name: "Sortie d'audience SPIP") }
      let(:organization) { build(:organization, organization_type: 'tj', spips: [organization2]) }

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
      let(:appointment_type) { create(:appointment_type, name: "Convocation de suivi JAP") }

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
