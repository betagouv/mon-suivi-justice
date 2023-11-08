require 'rails_helper'

describe UserPolicy do
  subject { UserPolicy.new(user, tested_user) }

  let(:tested_user) { build(:user, :in_organization) }

  context 'check_ownership' do
    context 'should be called by' do
      let(:user) { build(:user, :in_organization, role: 'local_admin') }
      it 'show' do
        expect(subject).to receive(:check_ownership)
        subject.show?
      end
      it 'update' do
        expect(subject).to receive(:check_ownership)
        subject.update?
      end
      it 'destroy' do
        expect(subject).to receive(:check_ownership)
        subject.destroy?
      end
      it 'index' do
        expect(subject).to receive(:check_ownership)
        subject.destroy?
      end
      it 'create' do
        expect(subject).to receive(:check_ownership)
        subject.destroy?
      end
    end
    context 'for a local_admin' do
      context 'own self' do
        let(:user) { build(:user, :in_organization, role: 'local_admin') }
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:user) { build(:user, role: 'local_admin', organization: tested_user.organization) }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user outside organization' do
        let(:organization) { build(:organization) }
        let(:user) { build(:user, role: 'local_admin', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a dir_greff_bex' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:user) { build(:user, role: 'dir_greff_bex', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a dir_greff_sap' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:user) { build(:user, role: 'dir_greff_sap', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a greff_sap' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:user) { build(:user, role: 'greff_sap', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a greff_co' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:user) { build(:user, role: 'greff_co', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a greff_ca' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:user) { build(:user, role: 'greff_ca', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a greff_crpc' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:user) { build(:user, role: 'greff_crpc', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a greff_tpe' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:user) { build(:user, role: 'greff_tpe', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a prosecutor' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:user) { build(:user, role: 'prosecutor', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a jap' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:user) { build(:user, role: 'jap', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a secretary_court' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:user) { build(:user, role: 'secretary_court', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a bex' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:user) { build(:user, role: 'bex', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for an admin' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:user) { build(:user, role: 'admin', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
    end

    context 'for a cpip' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:user) { build(:user, role: 'cpip', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'educator', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a dpip' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:user) { build(:user, role: 'dpip', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'educator', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for an educator' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:user) { build(:user, role: 'educator', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'educator', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a psychologist' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:user) { build(:user, role: 'psychologist', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'educator', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for an overseer' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:user) { build(:user, role: 'overseer', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'educator', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a secretary_spip' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:user) { build(:user, role: 'secretary_spip', organization:) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'educator', organization:) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
  end

  context 'for an admin' do
    let(:user) { build(:user, role: 'admin') }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a local_admin' do
    let(:user) { build(:user, role: 'local_admin', organization: tested_user.organization) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, role: 'prosecutor') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a jap user' do
    let(:user) { build(:user, role: 'jap') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a court secretary' do
    let(:user) { build(:user, role: 'secretary_court') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a dir_greff_bex user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'dir_greff_bex', organization:) }
    let(:tested_user) { build(:user, organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a bex user' do
    let(:user) { build(:user, role: 'bex') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a greff_co user' do
    let(:user) { build(:user, role: 'greff_co') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a dir_greff_sap user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'dir_greff_sap', organization:) }
    let(:tested_user) { build(:user, organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a greff_sap user' do
    let(:user) { build(:user, role: 'greff_sap') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a cpip user' do
    let(:user) { build(:user, role: 'cpip') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a educator user' do
    let(:user) { build(:user, role: 'educator') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a psychologist user' do
    let(:user) { build(:user, role: 'psychologist') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a overseer user' do
    let(:user) { build(:user, role: 'overseer') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a dpip user' do
    let(:user) { build(:user, role: 'dpip') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a secretary_spip user' do
    let(:user) { build(:user, role: 'secretary_spip') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end
end
