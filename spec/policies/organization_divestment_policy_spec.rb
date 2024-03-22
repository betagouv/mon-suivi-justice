require 'rails_helper'

describe OrganizationDivestmentPolicy do
  subject { OrganizationDivestmentPolicy.new(user, organization_divestment) }

  let(:user_to) { create(:user, :in_organization, type: :tj, role: :local_admin) }
  let(:divestment) { create(:divestment, organization: user_to.organization, user: user_to) }
  let(:user) { user_from }
  let(:organization) { user.organization }
  let(:organization_divestment) { create(:organization_divestment, organization:, divestment:) }

  context('user did not accept cgu') do
    let(:user_from) do
      create(:user, :in_organization, type: :tj, role: :local_admin, security_charter_accepted_at: nil)
    end

    it { is_expected.to forbid_action(:validate) }
  end

  context('organization_divestment is not pending') do
    let(:user_from) { create(:user, :in_organization, type: :tj, role: :local_admin) }
    let(:organization_divestment) do
      create(:organization_divestment, organization:, divestment:,
                                       state: :auto_accepted)
    end

    it { is_expected.to forbid_action(:validate) }
  end

  context('ownership') do
    let(:user_from) { create(:user, :in_organization, type: :tj, role: :local_admin) }
    let(:organization) { create(:organization) }

    it { is_expected.to forbid_action(:validate) }
  end

  context('per role') do
    context('user is local admin') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :local_admin) }

      it { is_expected.to permit_action(:validate) }
    end

    context('user is admin') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :admin) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is cpip') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :cpip) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is dpip') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :dpip) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is overseer') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :overseer) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is educator') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :educator) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is ') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :admin) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is admin') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :admin) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is admin') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :admin) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is admin') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :admin) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is admin') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :admin) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is admin') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :admin) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is admin') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :admin) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is admin') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :admin) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is bex') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :bex) }

      it { is_expected.to forbid_action(:validate) }
    end

    context('user is admin') do
      let(:user_from) { create(:user, :in_organization, type: :tj, role: :admin) }

      it { is_expected.to forbid_action(:validate) }
    end
  end
end
