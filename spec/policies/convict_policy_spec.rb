require 'rails_helper'

describe ConvictPolicy do
  subject { ConvictPolicy.new(user, convict) }

  context 'for a user who has not accepted the security charter' do
    let(:user) { build(:user, :in_organization, role: 'admin', security_charter_accepted_at: nil) }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    subject { ConvictPolicy.new(user, convict) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for an admin' do
    let(:user) { build(:user, :in_organization, role: 'admin') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    subject { ConvictPolicy.new(user, convict) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization) }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a local_admin' do
    let(:user) { build(:user, :in_organization, role: 'local_admin') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization) }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'prosecutor') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a jap user' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'jap') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a court secretary' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'secretary_court') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a dir_greff_bex user' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'dir_greff_bex') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end
  end

  context 'for a bex user' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'bex') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a greff_co user' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'greff_co') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a dir_greff_sap user' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'dir_greff_sap') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a greff_sap user' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'greff_sap') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a cpip user' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'cpip') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a educator user' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'educator') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a psychologist user' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'psychologist') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a overseer user' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'overseer') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a dpip user' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'dpip') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context 'for a secretary_spip user' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'secretary_spip') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end
end
