require 'rails_helper'

describe OrganizationDivestmentPolicy do
  subject { OrganizationDivestmentPolicy.new(user, organization_divestment) }

  let(:user) { user_from }
  let(:user_to) { create(:user, :in_organization, type: :tj, role: :local_admin) }
  let(:convict) { create(:convict, organizations: [user.organization]) }
  let(:divestment) { create(:divestment, organization: user_to.organization, user: user_to, convict:) }
  let(:organization) { user.organization }
  let(:organization_divestment) { create(:organization_divestment, organization:, divestment:) }

  context('user did not accept cgu') do
    let(:user_from) do
      create(:user, :in_organization, type: :tj, role: :local_admin, security_charter_accepted_at: nil)
    end

    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context('convict is invalid') do
    let(:user_from) { create(:user, :in_organization, type: :tj, role: :local_admin) }

    let(:convict) do
      c = build(:convict, organizations: [user.organization], appi_uuid: 'invalid')
      c.save(validate: false)
      c
    end

    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context('organization_divestment is not pending') do
    let(:user_from) { create(:user, :in_organization, type: :tj, role: :local_admin) }
    let(:organization_divestment) do
      create(:organization_divestment, organization:, divestment:,
                                       state: :auto_accepted)
    end

    it { is_expected.to forbid_action(:update) }
  end

  context('ownership') do
    let(:user_from) { create(:user, :in_organization, type: :tj, role: :local_admin) }
    let(:organization) { create(:organization) }

    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context('per role') do
    context('user is local admin') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :local_admin) }

      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
    end

    context('user is admin') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :admin) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is cpip') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :cpip) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is dpip') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :dpip) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is overseer') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :overseer) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is educator') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :educator) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is psychologist') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :psychologist) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is secretary_spip') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :secretary_spip) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is bex') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :bex) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is greff_tpe') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :greff_tpe) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is prosecutor') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :prosecutor) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is greff_co') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :greff_co) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is greff_crpc') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :greff_crpc) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is greff_ca') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :greff_ca) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is dir_greff_bex') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :dir_greff_bex) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end

    context('user is jap') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :jap) }

      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
    end

    context('user is greff_sap') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :greff_sap) }

      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
    end

    context('user is dir_greff_sap') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :dir_greff_sap) }

      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
    end

    context('user is secretary_court') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :secretary_court) }

      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
    end
  end
end
