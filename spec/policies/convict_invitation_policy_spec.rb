require 'rails_helper'

describe ConvictPolicy do
  subject { ConvictInvitationPolicy.new(user, convict) }

  context 'for an admin' do
    let(:user) { build(:user, role: 'admin') }
    let(:convict) { build(:convict) }

    it { is_expected.to permit_action(:create) }
  end

  context 'for a local_admin' do
    let(:user) { build(:user, role: 'local_admin') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, role: 'prosecutor') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a jap user' do
    let(:user) { build(:user, role: 'jap') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a court secretary' do
    let(:user) { build(:user, role: 'secretary_court') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a dir_greff_bex user' do
    let(:user) { build(:user, role: 'dir_greff_bex') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a bex user' do
    let(:user) { build(:user, role: 'bex') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a greff_co user' do
    let(:user) { build(:user, role: 'greff_co') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a dir_greff_sap user' do
    let(:user) { build(:user, role: 'dir_greff_sap') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a greff_sap user' do
    let(:user) { build(:user, role: 'greff_sap') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a cpip user' do
    let(:user) { build(:user, role: 'cpip') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a cpip user linked to correct convict' do
    let(:user) { build(:user, role: 'cpip') }
    let(:convict) { build(:convict, user: user) }

    it { is_expected.to permit_action(:create) }
  end

  context 'for a educator user' do
    let(:user) { build(:user, role: 'educator') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a psychologist user' do
    let(:user) { build(:user, role: 'psychologist') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a overseer user' do
    let(:user) { build(:user, role: 'overseer') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a dpip user' do
    let(:user) { build(:user, role: 'dpip') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end

  context 'for a secretary_spip user' do
    let(:user) { build(:user, role: 'secretary_spip') }
    let(:convict) { build(:convict) }

    it { is_expected.not_to permit_action(:create) }
  end
end
