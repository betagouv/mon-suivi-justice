require 'rails_helper'

describe UserServiceSwitchPolicy do
  subject { described_class.new(user, user) }

  let(:headquarter) { build(:headquarter) }
  let(:organization) { create(:organization, headquarter:, organization_type: 'spip') }
  let(:organization_outside_of_hq) { build(:organization, organization_type: 'spip') }

  context 'for a user who has not accepted the security charter' do
    let(:user) do
      build(:user, organization:, role: 'local_admin', headquarter:,
                   security_charter_accepted_at: nil)
    end
    it { is_expected.to forbid_action(:create) }
  end

  context 'for an admin' do
    let(:user) { build(:user, organization:, role: 'admin') }
    it { is_expected.to permit_action(:create) }
  end

  context 'for a bex' do
    let(:user) { build(:user, organization:, role: 'bex') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a cpip' do
    let(:user) { build(:user, organization:, role: 'cpip') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a local_admin with headquarter' do
    let(:user) { build(:user, organization:, role: 'local_admin', headquarter:) }
    it { is_expected.to permit_action(:create) }
  end

  context 'for an local_admin with headquarter changing outside of headquarter' do
    let(:user) { build(:user, organization: organization_outside_of_hq, role: 'local_admin', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a local_admin without headquarter' do
    let(:user) { build(:user, organization:, role: 'local_admin', headquarter: nil) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, organization:, role: 'prosecutor', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a jap' do
    let(:user) { build(:user, organization:, role: 'jap', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a secretary_court' do
    let(:user) { build(:user, organization:, role: 'secretary_court', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a dir_greff_bex' do
    let(:user) { build(:user, organization:, role: 'dir_greff_bex', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a greff_co' do
    let(:user) { build(:user, organization:, role: 'greff_co', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a dir_greff_sap' do
    let(:user) { build(:user, organization:, role: 'dir_greff_sap', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a greff_sap' do
    let(:user) { build(:user, organization:, role: 'greff_sap', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for an educator' do
    let(:user) { build(:user, organization:, role: 'educator', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a psychologist with headquarter' do
    let(:user) { build(:user, organization:, role: 'psychologist', headquarter:) }
    it { is_expected.to permit_action(:create) }
  end

  context 'for an psychologist with headquarter changing outside of headquarter' do
    let(:user) { build(:user, organization: organization_outside_of_hq, role: 'psychologist', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a psychologist without headquarter' do
    let(:user) { build(:user, organization:, role: 'psychologist', headquarter: nil) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for an overseer with headquarter' do
    let(:user) { build(:user, organization:, role: 'overseer', headquarter:) }
    it { is_expected.to permit_action(:create) }
  end

  context 'for an overseer with headquarter changing outside of headquarter' do
    let(:user) { build(:user, organization: organization_outside_of_hq, role: 'overseer', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for an overseer without headquarter' do
    let(:user) { build(:user, organization:, role: 'overseer', headquarter: nil) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a dpip' do
    let(:user) { build(:user, organization:, role: 'dpip', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a secretary_spip' do
    let(:user) { build(:user, organization:, role: 'secretary_spip', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a greff_tpe' do
    let(:user) { build(:user, organization:, role: 'greff_tpe', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a greff_crpc' do
    let(:user) { build(:user, organization:, role: 'greff_crpc', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a greff_ca' do
    let(:user) { build(:user, organization:, role: 'greff_ca', headquarter:) }
    it { is_expected.to forbid_action(:create) }
  end
end
