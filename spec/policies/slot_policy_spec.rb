require 'rails_helper'

describe SlotPolicy do
  subject { SlotPolicy.new(user, slot) }

  let(:spip) { build(:organization, organization_type: 'spip') }
  let(:tj) { build(:organization, organization_type: 'tj', spips: [spip]) }
  let(:place) { build(:place, organization:) }
  let(:agenda) { build(:agenda, place:) }
  let(:slot) { build(:slot, agenda:) }

  context 'check_ownership?' do
    let(:organization) { tj }
    context 'should be called by' do
      let(:user) { build(:user, :in_organization, role: 'local_admin') }
      it 'show' do
        expect(subject).to receive(:check_ownership?)
        subject.show?
      end
      it 'update' do
        expect(subject).to receive(:check_ownership?)
        subject.update?
      end
      it 'destroy' do
        expect(subject).to receive(:check_ownership?)
        subject.destroy?
      end
      it 'create' do
        expect(subject).to receive(:check_ownership?)
        subject.create?
      end
      it 'edit' do
        expect(subject).to receive(:check_ownership?)
        subject.edit?
      end
      context 'batch slots' do
        subject { SlotPolicy.new(user, [slot]) }
        it 'update_all' do
          expect(subject).to receive(:check_ownership?)
          subject.update_all?
        end
      end
    end
    context 'for an admin' do
      let(:organization) { spip }

      context 'own slot in organization' do
        let(:user) { build(:user, role: 'admin', organization:) }
        it { expect(subject.send(:check_ownership?)).to eq(true) }
      end
      context 'does own slot in jurisdiction' do
        let(:user) { build(:user, role: 'admin', organization: tj) }
        it { expect(subject.send(:check_ownership?)).to eq(true) }
      end
      context 'does not own slot outside organization' do
        let(:other_organization) { build(:organization) }
        let(:user) { build(:user, role: 'admin', organization: other_organization) }
        it { expect(subject.send(:check_ownership?)).to eq(false) }
      end
    end
    context 'spip' do
      let(:organization) { spip }

      context 'for a local_admin' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'local_admin', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization) }
          let(:user) { build(:user, role: 'local_admin', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'local_admin', organization: tj) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a cpip' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'cpip', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'spip') }
          let(:user) { build(:user, role: 'cpip', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'cpip', organization: tj) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a dpip' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'dpip', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'spip') }
          let(:user) { build(:user, role: 'dpip', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'dpip', organization: tj) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a educator' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'educator', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'spip') }
          let(:user) { build(:user, role: 'educator', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'educator', organization: tj) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a psychologist' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'psychologist', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'spip') }
          let(:user) { build(:user, role: 'psychologist', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'psychologist', organization: tj) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a overseer' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'overseer', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'spip') }
          let(:user) { build(:user, role: 'overseer', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'overseer', organization: tj) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a secretary_spip' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'secretary_spip', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'spip') }
          let(:user) { build(:user, role: 'secretary_spip', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'secretary_spip', organization: tj) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
    end
    context 'tj' do
      let(:organization) { tj }
      context 'for a bex' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'bex', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'tj') }
          let(:user) { build(:user, role: 'bex', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'bex', organization: spip) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a prosecutor' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'prosecutor', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'tj') }
          let(:user) { build(:user, role: 'prosecutor', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'prosecutor', organization: spip) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a greff_crpc' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'greff_crpc', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'tj') }
          let(:user) { build(:user, role: 'greff_crpc', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'greff_crpc', organization: spip) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a greff_tpe' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'greff_tpe', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'tj') }
          let(:user) { build(:user, role: 'greff_tpe', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'greff_tpe', organization: spip) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a greff_co' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'greff_co', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'tj') }
          let(:user) { build(:user, role: 'greff_co', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'greff_co', organization: spip) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a greff_ca' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'greff_ca', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'tj') }
          let(:user) { build(:user, role: 'greff_ca', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'greff_ca', organization: spip) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a greff_ca' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'greff_ca', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'tj') }
          let(:user) { build(:user, role: 'greff_ca', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'greff_ca', organization: spip) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a dir_greff_bex' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'dir_greff_bex', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'tj') }
          let(:user) { build(:user, role: 'dir_greff_bex', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'dir_greff_bex', organization: spip) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a jap' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'jap', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'tj') }
          let(:user) { build(:user, role: 'jap', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'jap', organization: spip) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
      context 'for a greff_sap' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'greff_sap', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'tj') }
          let(:user) { build(:user, role: 'greff_sap', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'greff_sap', organization: spip) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end

      context 'for a dir_greff_sap' do
        context 'own slot in organization' do
          let(:user) { build(:user, role: 'dir_greff_sap', organization:) }
          it { expect(subject.send(:check_ownership?)).to eq(true) }
        end
        context 'does not own slot outside organization' do
          let(:other_organization) { build(:organization, organization_type: 'tj') }
          let(:user) { build(:user, role: 'dir_greff_sap', organization: other_organization) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
        context 'does not own slot in jurisdiction' do
          let(:user) { build(:user, role: 'dir_greff_sap', organization: spip) }
          it { expect(subject.send(:check_ownership?)).to eq(false) }
        end
      end
    end
  end

  context 'for a user who has not accepted the security charter' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'admin', organization:, security_charter_accepted_at: nil) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for an admin' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'admin', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to permit_action(:update_all) }
    end
  end

  context 'for a local_admin' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'local_admin', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to permit_action(:update_all) }
    end
  end

  context 'for a prosecutor' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'prosecutor', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to forbid_action(:update_all) }
    end
  end

  context 'for a jap user' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'jap', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to permit_action(:update_all) }
    end
  end

  context 'for a court secretary' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'secretary_court', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to permit_action(:update_all) }
    end
  end

  context 'for a dir_greff_bex user' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'dir_greff_bex', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to permit_action(:update_all) }
    end
  end

  context 'for a bex user' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'bex', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to forbid_action(:update_all) }
    end
  end

  context 'for a greff_co user' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'greff_co', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to forbid_action(:update_all) }
    end
  end

  context 'for a dir_greff_sap user' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'dir_greff_sap', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to permit_action(:update_all) }
    end
  end

  context 'for a greff_sap user' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'greff_sap', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to permit_action(:update_all) }
    end
  end

  context 'for a cpip user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'cpip', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to forbid_action(:update_all) }
    end
  end

  context 'for a educator user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'educator', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to forbid_action(:update_all) }
    end
  end

  context 'for a psychologist user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'psychologist', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to forbid_action(:update_all) }
    end
  end

  context 'for a overseer user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'overseer', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to permit_action(:update_all) }
    end
  end

  context 'for a dpip user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'dpip', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to permit_action(:update_all) }
    end
  end

  context 'for a secretary_spip user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'secretary_spip', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }

    context 'batch slots' do
      subject { SlotPolicy.new(user, [slot]) }
      it { is_expected.to forbid_action(:update_all) }
    end
  end
end
