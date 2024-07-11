require 'rails_helper'

describe DivestmentPolicy do
  subject { DivestmentPolicy.new(user_to, divestment) }

  let(:user) { create(:user, :in_organization, type: :tj, role: :cpip) }
  let(:convict) { create(:convict, organizations: [user.organization]) }
  let(:divestment) { build(:divestment, organization: user_to.organization, user: user_to, convict:) }

  context('user did not accept cgu') do
    let(:user_to) do
      create(:user, :in_organization, type: :tj, role: :local_admin, security_charter_accepted_at: nil)
    end

    it { is_expected.to forbid_action(:create) }
  end

  context('organization use inter-ressort') do
    let(:organization) { create(:organization, organization_type: :tj, use_inter_ressort: true) }
    let(:organization2) { create(:organization, organization_type: :tj) }
    let(:user_to) { create(:user, organization:, role: :bex) }
    let(:divestment) { build(:divestment, organization: organization2, user: user_to, convict:) }

    it { is_expected.to permit_action(:create) }
  end

  context('user and divestment org are not the same') do
    let(:organization) { create(:organization, organization_type: :tj) }
    let(:user_to) { create(:user, organization:, role: :secretary_court) }
    let(:organization2) { create(:organization, organization_type: :tj) }
    let(:divestment) { build(:divestment, organization: organization2, user: user_to, convict:) }

    it { is_expected.to forbid_action(:create) }
  end

  context('per role') do
    context('user is local admin') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :local_admin) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is admin') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :admin) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is cpip') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :cpip) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is dpip') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :dpip) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is overseer') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :overseer) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is educator') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :educator) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is psychologist') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :psychologist) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is secretary_spip') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :secretary_spip) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is bex') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :bex) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is greff_tpe') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :greff_tpe) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is prosecutor') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :prosecutor) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is greff_co') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :greff_co) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is greff_crpc') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :greff_crpc) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is greff_ca') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :greff_ca) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is dir_greff_bex') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :dir_greff_bex) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is jap') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :jap) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is greff_sap') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :greff_sap) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is dir_greff_sap') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :dir_greff_sap) }

      it { is_expected.to permit_action(:create) }
    end

    context('user is secretary_court') do
      let(:user_to) { create(:user, :in_organization, type: :tj, role: :secretary_court) }

      it { is_expected.to permit_action(:create) }
    end
  end
end
