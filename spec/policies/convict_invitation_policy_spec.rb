require 'rails_helper'

describe ConvictInvitationPolicy do
  subject { ConvictInvitationPolicy.new(user, convict) }

  context 'for an admin' do
    let(:user) { build(:user, role: 'admin') }
    let(:convict) { build(:convict) }

    it { is_expected.to permit_action(:create) }
  end

  context 'for an admin' do
    let(:user) { build(:user, role: 'admin', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to permit_action(:create) }
  end

  context 'for a local_admin' do
    let(:user) { build(:user, role: 'local_admin') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a local_admin' do
    let(:user) { build(:user, role: 'local_admin', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, role: 'prosecutor', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a jap user' do
    let(:user) { build(:user, role: 'jap', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a court secretary' do
    let(:user) { build(:user, role: 'secretary_court', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a dir_greff_bex user' do
    let(:user) { build(:user, role: 'dir_greff_bex', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a bex user' do
    let(:user) { build(:user, role: 'bex', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a greff_co user' do
    let(:user) { build(:user, role: 'greff_co', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a dir_greff_sap user' do
    let(:user) { build(:user, role: 'dir_greff_sap', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a greff_sap user' do
    let(:user) { build(:user, role: 'greff_sap', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a cpip user' do
    let(:user) { create(:user, :in_organization, role: 'cpip', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for the convict\'s cpip' do
    let(:user) { create(:user, :in_organization, role: 'cpip', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict, user:) }

    it { is_expected.to permit_action(:create) }
  end

  context 'for a educator user' do
    let(:user) { build(:user, role: 'educator', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a psychologist user' do
    let(:user) { build(:user, role: 'psychologist', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a overseer user' do
    let(:user) { build(:user, role: 'overseer', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a dpip user' do
    let(:user) { build(:user, role: 'dpip', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for a dpip user in convict\'s organization' do
    let(:user) { build(:user, :in_organization, role: 'dpip', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:create) }
  end

  context 'for a secretary_spip user' do
    let(:user) { build(:user, role: 'secretary_spip', email: 'delphine.deneubourg@justice.fr') }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end
end
