require 'rails_helper'

describe UserServiceSwitchPolicy do
  subject { described_class.new(user, nil) }
 
  let(:organization) { build(:organization, organization_type: "spip") }

  context 'for an admin' do
    let(:user) { build(:user, organization: organization, role: 'admin') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a bex' do
    let(:user) { build(:user, organization: organization, role: 'bex') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a cpip' do
    let(:user) { build(:user, organization: organization, role: 'cpip') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a local_admin with headquarter' do
    let(:user) { build(:user, organization: organization, role: 'local_admin', headquarter: build(:headquarter)) }
    it { is_expected.to permit_action(:create) }
  end

  context 'for a local_admin without headquarter' do
    let(:user) { build(:user, organization: organization, role: 'local_admin', headquarter: nil) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, organization: organization, role: 'prosecutor') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a jap' do
    let(:user) { build(:user, organization: organization, role: 'jap') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a secretary_court' do
    let(:user) { build(:user, organization: organization, role: 'secretary_court') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a dir_greff_bex' do
    let(:user) { build(:user, organization: organization, role: 'dir_greff_bex') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a greff_co' do
    let(:user) { build(:user, organization: organization, role: 'greff_co') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a dir_greff_sap' do
    let(:user) { build(:user, organization: organization, role: 'dir_greff_sap') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a greff_sap' do
    let(:user) { build(:user, organization: organization, role: 'greff_sap') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for an educator' do
    let(:user) { build(:user, organization: organization, role: 'educator') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a psychologist with headquarter' do
    let(:user) { build(:user, organization: organization, role: 'psychologist', headquarter: build(:headquarter)) }
    it { is_expected.to permit_action(:create) }
  end

  context 'for a psychologist without headquarter' do
    let(:user) { build(:user, organization: organization, role: 'psychologist', headquarter: nil) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for an overseer with headquarter' do
    let(:user) { build(:user, organization: organization, role: 'overseer', headquarter: build(:headquarter)) }
    it { is_expected.to permit_action(:create) }
  end

  context 'for an overseer without headquarter' do
    let(:user) { build(:user, organization: organization, role: 'overseer', headquarter: nil) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a dpip' do
    let(:user) { build(:user, organization: organization, role: 'dpip') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a secretary_spip' do
    let(:user) { build(:user, organization: organization, role: 'secretary_spip') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a greff_tpe' do
    let(:user) { build(:user, organization: organization, role: 'greff_tpe') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a greff_crpc' do
    let(:user) { build(:user, organization: organization, role: 'greff_crpc') }
    it { is_expected.to forbid_action(:create) }
  end

  context 'for a greff_ca' do
    let(:user) { build(:user, organization: organization, role: 'greff_ca') }
    it { is_expected.to forbid_action(:create) }
  end
end
