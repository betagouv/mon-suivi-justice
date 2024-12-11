require 'rails_helper'

describe NotificationTypePolicy do
  subject { NotificationTypePolicy.new(user, notification_type) }

  let(:user_role) { :admin }
  let(:organization_type) { :tj }
  let(:user) { create(:user, :in_organization, type: organization_type, role: user_role) }
  let(:organization) { user.organization }
  let(:is_default) { false }
  let(:still_default) { false }
  let(:notification_type) { create(:notification_type, still_default:, is_default:, organization:) }

  context('user did not accept cgu') do
    let(:user) do
      create(:user, :in_organization, type: :tj, role: :local_admin, security_charter_accepted_at: nil)
    end

    it { is_expected.to forbid_action(:update) }
  end

  context('notification type is default') do
    let(:is_default) { true }
    let(:organization) { nil }
    it { is_expected.to forbid_action(:update) }
  end

  context('notification type is still default') do
    let(:still_default) { true }

    it { is_expected.to forbid_action(:update) }
  end

  context('per role') do
    context('user is admin') do
      let(:user_role) { :admin }

      it { is_expected.to permit_action(:update) }
    end

    context('user is local admin') do
      let(:user_role) { :local_admin }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is cpip') do
      let(:user_role) { :cpip }
      let(:organization_type) { 'spip' }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is dpip') do
      let(:user_role) { :dpip }
      let(:organization_type) { 'spip' }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is overseer') do
      let(:user_role) { :overseer }
      let(:organization_type) { 'spip' }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is educator') do
      let(:user_role) { :educator }
      let(:organization_type) { 'spip' }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is psychologist') do
      let(:user_role) { :psychologist }
      let(:organization_type) { 'spip' }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is secretary_spip') do
      let(:user_role) { :secretary_spip }
      let(:organization_type) { 'spip' }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is bex') do
      let(:user_role) { :bex }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is greff_tpe') do
      let(:user_role) { :greff_tpe }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is prosecutor') do
      let(:user_role) { :prosecutor }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is greff_co') do
      let(:user_role) { :greff_co }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is greff_crpc') do
      let(:user_role) { :greff_crpc }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is greff_ca') do
      let(:user_role) { :greff_ca }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is dir_greff_bex') do
      let(:user_role) { :dir_greff_bex }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is jap') do
      let(:user_role) { :jap }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is greff_sap') do
      let(:user_role) { :greff_sap }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is dir_greff_sap') do
      let(:user_role) { :dir_greff_sap }

      it { is_expected.to forbid_action(:update) }
    end

    context('user is secretary_court') do
      let(:user_role) { :secretary_court }

      it { is_expected.to forbid_action(:update) }
    end
  end
end
