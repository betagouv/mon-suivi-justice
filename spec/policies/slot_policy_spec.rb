require 'rails_helper'

describe SlotPolicy do
  subject { SlotPolicy.new(user, slot) }

  let(:spip) { build(:organization, organization_type: 'spip') }
  let(:tj) { build(:organization, organization_type: 'tj', spips: [spip]) }
  let(:organization) { spip }
  let(:place) { build(:place, organization:) }
  let(:agenda) { build(:agenda, place:) }
  let(:slot) { build(:slot, agenda:) }

  context 'check_ownership?' do
    context 'should be called by' do
      let(:user) { build(:user, :in_organization, role: 'local_admin') }
      it 'index' do
        expect(subject).to receive(:check_ownership?)
        subject.show?
      end
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
        subject.destroy?
      end
    end
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
    context 'for an admin' do
      context 'own slot in organization' do
        let(:user) { build(:user, role: 'admin', organization:) }
        it { expect(subject.send(:check_ownership?)).to eq(true) }
      end
      context 'does not own slot outside organization' do
        let(:other_organization) { build(:organization) }
        let(:user) { build(:user, role: 'admin', organization: other_organization) }
        it { expect(subject.send(:check_ownership?)).to eq(false) }
      end
      context 'does own slot in jurisdiction' do
        let(:user) { build(:user, role: 'admin', organization: tj) }
        it { expect(subject.send(:check_ownership?)).to eq(true) }
      end
    end
  end

  context 'for an admin' do
    let(:user) { build(:user, role: 'admin', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a local_admin' do
    let(:user) { build(:user, role: 'local_admin', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, role: 'prosecutor', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a jap user' do
    let(:user) { build(:user, role: 'jap', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a court secretary' do
    let(:user) { build(:user, role: 'secretary_court', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a dir_greff_bex user' do
    let(:user) { build(:user, role: 'dir_greff_bex', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a bex user' do
    let(:user) { build(:user, role: 'bex', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a greff_co user' do
    let(:user) { build(:user, role: 'greff_co', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a dir_greff_sap user' do
    let(:user) { build(:user, role: 'dir_greff_sap', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a greff_sap user' do
    let(:user) { build(:user, role: 'greff_sap', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a cpip user' do
    let(:user) { build(:user, role: 'cpip', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a educator user' do
    let(:user) { build(:user, role: 'educator', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a psychologist user' do
    let(:user) { build(:user, role: 'psychologist', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a overseer user' do
    let(:user) { build(:user, role: 'overseer', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a dpip user' do
    let(:user) { build(:user, role: 'dpip', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a secretary_spip user' do
    let(:user) { build(:user, role: 'secretary_spip', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end
end
