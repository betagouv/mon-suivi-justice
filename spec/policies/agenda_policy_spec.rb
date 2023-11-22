require 'rails_helper'

describe AgendaPolicy do
  subject { AgendaPolicy.new(user, agenda) }

  let(:spip) { build(:organization, organization_type: 'spip') }
  let(:tj) { build(:organization, organization_type: 'tj', spips: [spip]) }
  let(:place) { build(:place, organization:) }
  let(:agenda) { build(:agenda, place:) }

  context 'for an admin' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'admin', organization:) }

    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a local_admin' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'local_admin', organization:) }

    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a prosecutor' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'prosecutor', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a jap user' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'jap', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a court secretary' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'secretary_court', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a dir_greff_bex user' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'dir_greff_bex', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a bex user' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'bex', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a greff_co user' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'greff_co', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a dir_greff_sap user' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'dir_greff_sap', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a greff_sap user' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'greff_sap', organization:) }

    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'for a cpip user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'cpip', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a educator user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'educator', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a psychologist user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'psychologist', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a overseer user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'overseer', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a dpip user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'dpip', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context 'for a secretary_spip user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'secretary_spip', organization:) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end
end
