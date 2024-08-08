require 'rails_helper'

describe UserPolicy do
  subject { described_class.new(user, tested_user) }

  let(:tested_user) { build(:user, :in_organization) }
  let(:tj) { build(:organization, organization_type: 'tj') }
  let(:spip) { build(:organization, organization_type: 'spip') }

  describe '#authorized_role?' do
    context 'should be called by' do
      let(:user) { build(:user, :in_organization, role: 'local_admin') }
      before { allow(subject).to receive(:check_ownership).and_return(true) }

      it 'update' do
        expect(subject).to receive(:authorized_role?)
        subject.update?
      end
      it 'create' do
        expect(subject).to receive(:authorized_role?)
        subject.create?
      end
    end
    describe 'only allow to manage correct roles' do
      context 'when user is admin and record too' do
        let(:user) { build(:user, role: 'admin') }
        let(:tested_user) { build(:user, role: 'admin') }

        it { expect(subject.send(:authorized_role?)).to eq(true) }
      end
      context 'when user is admin and record local_admin' do
        let(:user) { build(:user, role: 'admin') }
        let(:tested_user) { build(:user, role: 'local_admin') }

        it { expect(subject.send(:authorized_role?)).to eq(true) }
      end
      context 'when user is admin and record regular user' do
        let(:user) { build(:user, role: 'admin') }
        let(:tested_user) { build(:user, role: 'cpip') }

        it { expect(subject.send(:authorized_role?)).to eq(true) }
      end
      context 'when user is local_admin and record admin' do
        let(:user) { build(:user, role: 'local_admin') }
        let(:tested_user) { build(:user, role: 'admin') }

        it { expect(subject.send(:authorized_role?)).to eq(false) }
      end
      context 'when user is local_admin and record too' do
        let(:user) { build(:user, role: 'local_admin') }
        let(:tested_user) { build(:user, role: 'local_admin') }

        it { expect(subject.send(:authorized_role?)).to eq(true) }
      end
      context 'when user is local_admin and record regular user' do
        let(:user) { build(:user, role: 'local_admin') }
        let(:tested_user) { build(:user, role: 'cpip') }

        it { expect(subject.send(:authorized_role?)).to eq(true) }
      end
      context 'when user is regular user and record admin' do
        let(:user) { build(:user, role: 'cpip') }
        let(:tested_user) { build(:user, role: 'admin') }

        it { expect(subject.send(:authorized_role?)).to eq(false) }
      end
      context 'when user is regular user and record local_admin' do
        let(:user) { build(:user, role: 'cpip') }
        let(:tested_user) { build(:user, role: 'local_admin') }

        it { expect(subject.send(:authorized_role?)).to eq(false) }
      end
      context 'when user is regular user and record too' do
        let(:user) { build(:user, role: 'cpip') }
        let(:tested_user) { build(:user, role: 'cpip') }

        it { expect(subject.send(:authorized_role?)).to eq(true) }
      end
    end
  end

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
      it 'create' do
        expect(subject).to receive(:check_ownership)
        subject.create?
      end
    end
    context 'generic' do
      context 'own self' do
        let(:user) { build(:user, :in_organization, role: 'local_admin') }
        let(:tested_user) { user }

        context 'organization change' do
          subject { UserPolicy.new(user, tested_user) }
          before { allow(subject).to receive(:same_organization?).and_return(false) }

          it 'cannot change his organization (outside of his antennas)' do
            expect(subject.send(:check_ownership)).to be false
          end
        end

        context 'role change' do
          subject { UserPolicy.new(user, tested_user) }
          before { allow(subject).to receive(:same_organization?).and_return(false) }

          it 'cannot change his organization (outside of his antennas)' do
            expect(subject.send(:check_ownership)).to be false
          end
        end
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
      let(:user) { build(:user, role: 'dir_greff_bex', organization: tj) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization: tj) }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a dir_greff_sap' do
      let(:user) { build(:user, role: 'dir_greff_sap', organization: tj) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization: tj) }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a greff_sap' do
      let(:user) { build(:user, role: 'greff_sap', organization: tj) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization: tj) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a greff_co' do
      let(:user) { build(:user, role: 'greff_co', organization: tj) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization: tj) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a greff_ca' do
      let(:user) { build(:user, role: 'greff_ca', organization: tj) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization: tj) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a greff_crpc' do
      let(:user) { build(:user, role: 'greff_crpc', organization: tj) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization: tj) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a greff_tpe' do
      let(:user) { build(:user, role: 'greff_tpe', organization: tj) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization: tj) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a prosecutor' do
      let(:user) { build(:user, role: 'prosecutor', organization: tj) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization: tj) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a jap' do
      let(:user) { build(:user, role: 'jap', organization: tj) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization: tj) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a secretary_court' do
      let(:user) { build(:user, role: 'secretary_court', organization: tj) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization: tj) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a bex' do
      let(:user) { build(:user, role: 'bex', organization: tj) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization: tj) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for an admin' do
      let(:user) { build(:user, role: 'admin', organization: tj) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'greff_sap', organization: tj) }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
    end

    context 'for a cpip' do
      let(:user) { build(:user, role: 'cpip', organization: spip) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'educator', organization: spip) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a dpip' do
      let(:user) { build(:user, role: 'dpip', organization: spip) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'educator', organization: spip) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for an educator' do
      let(:user) { build(:user, role: 'educator', organization: spip) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'own user in organization' do
        let(:tested_user) { build(:user, role: 'educator', organization: spip) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a psychologist' do
      let(:user) { build(:user, role: 'psychologist', organization: spip) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'educator', organization: spip) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for an overseer' do
      let(:user) { build(:user, role: 'overseer', organization: spip) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'educator', organization: spip) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
    context 'for a secretary_spip' do
      let(:user) { build(:user, role: 'secretary_spip', organization: spip) }
      context 'own self' do
        let(:tested_user) { user }
        it { expect(subject.send(:check_ownership)).to eq(true) }
      end
      context 'does not own user in organization' do
        let(:tested_user) { build(:user, role: 'educator', organization: spip) }
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
      context 'does not own user outside organization' do
        it { expect(subject.send(:check_ownership)).to eq(false) }
      end
    end
  end

  context 'for a user who has not accepted the security charter' do
    let(:organization) { tested_user.organization }
    let(:user) { build(:user, role: 'admin', organization:, security_charter_accepted_at: nil) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for an admin' do
    let(:organization) { tested_user.organization }
    let(:user) { build(:user, role: 'admin', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:mutate) }

    context 'for a user in another organization type' do
      let(:organization) { tj }
      let(:tested_user) { build(:user, organization: spip) }

      it { is_expected.to forbid_action(:mutate) }
    end
  end

  context 'for a local_admin' do
    let(:organization) { tested_user.organization }
    let(:user) { build(:user, role: 'local_admin', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:mutate) }

    context 'for a user in another organization type' do
      let(:organization) { tj }
      let(:tested_user) { build(:user, organization: spip) }

      it { is_expected.to forbid_action(:mutate) }
    end
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, organization: tj, role: 'prosecutor') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a jap user' do
    let(:user) { build(:user, organization: tj, role: 'jap') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a court secretary' do
    let(:user) { build(:user, organization: tj, role: 'secretary_court') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a dir_greff_bex user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'dir_greff_bex', organization:) }
    let(:tested_user) { build(:user, role: 'jap', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a bex user' do
    let(:user) { build(:user, organization: tj, role: 'bex') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a greff_co user' do
    let(:user) { build(:user, organization: tj, role: 'greff_co') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a dir_greff_sap user' do
    let(:organization) { build(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'dir_greff_sap', organization:) }
    let(:tested_user) { build(:user, role: 'jap', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a greff_sap user' do
    let(:user) { build(:user, organization: tj, role: 'greff_sap') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a cpip user' do
    let(:user) { build(:user, organization: spip, role: 'cpip') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a educator user' do
    let(:user) { build(:user, organization: spip, role: 'educator') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a psychologist user' do
    let(:user) { build(:user, organization: spip, role: 'psychologist') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a overseer user' do
    let(:user) { build(:user, organization: spip, role: 'overseer') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a dpip user' do
    let(:user) { build(:user, organization: spip, role: 'dpip') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end

  context 'for a secretary_spip user' do
    let(:user) { build(:user, organization: spip, role: 'secretary_spip') }
    let(:tested_user) { user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:mutate) }
  end
end
