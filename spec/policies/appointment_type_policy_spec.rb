require 'rails_helper'

describe AppointmentTypePolicy do
  subject { AppointmentTypePolicy.new(user, appointment_type) }

  let(:appointment_type) { build(:appointment_type) }

  context 'for a user who has not accepted the security charter' do
    let(:user) { build(:user, role: 'admin', security_charter_accepted_at: nil) }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for an admin' do
    let(:user) { build(:user, role: 'admin') }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
  end

  context 'for a local_admin' do
    let(:user) { build(:user, role: 'local_admin') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, role: 'prosecutor') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a jap user' do
    let(:user) { build(:user, role: 'jap') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a court secretary' do
    let(:user) { build(:user, role: 'secretary_court') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a dir_greff_bex user' do
    let(:user) { build(:user, role: 'dir_greff_bex') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a bex user' do
    let(:user) { build(:user, role: 'bex') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a greff_co user' do
    let(:user) { build(:user, role: 'greff_co') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a dir_greff_sap user' do
    let(:user) { build(:user, role: 'dir_greff_sap') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a greff_sap user' do
    let(:user) { build(:user, role: 'greff_sap') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a cpip user' do
    let(:user) { build(:user, role: 'cpip') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a educator user' do
    let(:user) { build(:user, role: 'educator') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a psychologist user' do
    let(:user) { build(:user, role: 'psychologist') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a overseer user' do
    let(:user) { build(:user, role: 'overseer') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a dpip user' do
    let(:user) { build(:user, role: 'dpip') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for a secretary_spip user' do
    let(:user) { build(:user, role: 'secretary_spip') }

    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end
end
