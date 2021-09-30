require 'rails_helper'

describe AppointmentPolicy do
  subject { AppointmentPolicy.new(user, appointment) }

  let(:appointment) { build(:appointment) }

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
    it { is_expected.to permit_action(:index_today) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
  end

  context 'for a bex user' do
    let(:user) { build(:user, role: 'bex') }

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
    it { is_expected.to forbid_action(:index_today) }
    it { is_expected.to permit_action(:agenda_jap) }
    it { is_expected.to permit_action(:agenda_spip) }
  end

  context 'for a cpip user' do
    let(:user) { build(:user, role: 'cpip') }

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
    it { is_expected.to permit_action(:index_today) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }
  end

  context 'for a sap user' do
    let(:user) { build(:user, role: 'sap') }

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
    it { is_expected.to permit_action(:index_today) }
    it { is_expected.to forbid_action(:agenda_jap) }
    it { is_expected.to forbid_action(:agenda_spip) }
  end
end
