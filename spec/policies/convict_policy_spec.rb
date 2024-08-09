require 'rails_helper'

describe ConvictPolicy do
  subject { ConvictPolicy.new(user, convict) }

  context 'for a user who has not accepted the security charter' do
    let(:user) { build(:user, :in_organization, role: 'admin', security_charter_accepted_at: nil) }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    subject { ConvictPolicy.new(user, convict) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }
    it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
  end

  context 'convokable during divestment' do
    context 'no divestment pending' do
      let(:convict) { create(:convict) }

      context('user is local admin') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :local_admin) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is admin') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :admin) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is cpip') do
        let(:user) { create(:user, :in_organization, type: :spip, role: :cpip) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is dpip') do
        let(:user) { create(:user, :in_organization, type: :spip, role: :dpip) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is overseer') do
        let(:user) { create(:user, :in_organization, type: :spip, role: :overseer) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is educator') do
        let(:user) { create(:user, :in_organization, type: :spip, role: :educator) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is psychologist') do
        let(:user) { create(:user, :in_organization, type: :spip, role: :psychologist) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is secretary_spip') do
        let(:user) { create(:user, :in_organization, type: :spip, role: :secretary_spip) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is bex') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :bex) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is greff_tpe') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :greff_tpe) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is prosecutor') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :prosecutor) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is greff_co') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :greff_co) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is greff_crpc') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :greff_crpc) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is greff_ca') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :greff_ca) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is dir_greff_bex') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :dir_greff_bex) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is jap') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :jap) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is greff_sap') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :greff_sap) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is dir_greff_sap') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :dir_greff_sap) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is secretary_court') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :secretary_court) }

        it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
      end
    end
    context 'a divestment pending' do
      let(:convict) { create(:convict) }
      let!(:divestment) { create(:divestment, state: 'pending', convict:, user:, organization: user.organization) }
      context('user is local admin') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :local_admin) }

        it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is admin') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :admin) }

        it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is cpip') do
        let(:user) { create(:user, :in_organization, type: :spip, role: :cpip) }

        it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is dpip') do
        let(:user) { create(:user, :in_organization, type: :spip, role: :dpip) }

        it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is overseer') do
        let(:user) { create(:user, :in_organization, type: :spip, role: :overseer) }

        it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is educator') do
        let(:user) { create(:user, :in_organization, type: :spip, role: :educator) }

        it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is psychologist') do
        let(:user) { create(:user, :in_organization, type: :spip, role: :psychologist) }

        it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is secretary_spip') do
        let(:user) { create(:user, :in_organization, type: :spip, role: :secretary_spip) }

        it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
      end

      context 'bex' do
        context "when the divestment is to the user's organization" do
          let!(:divestment) { create(:divestment, state: 'pending', convict:, user:, organization: user.organization) }

          context('user is bex') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :bex) }

            it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
          end

          context('user is greff_tpe') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :greff_tpe) }

            it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
          end

          context('user is prosecutor') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :prosecutor) }

            it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
          end

          context('user is greff_co') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :greff_co) }

            it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
          end

          context('user is greff_crpc') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :greff_crpc) }

            it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
          end

          context('user is greff_ca') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :greff_ca) }

            it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
          end

          context('user is dir_greff_bex') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :dir_greff_bex) }

            it { is_expected.to permit_action(:no_divestment_or_convokable_nonetheless) }
          end
        end
        context "when the divestment is NOT to the user's organization" do
          let!(:organization) { create(:organization) }
          let!(:divestment) { create(:divestment, state: 'pending', convict:, user:, organization:) }

          context('user is bex') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :bex) }

            it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
          end

          context('user is greff_tpe') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :greff_tpe) }

            it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
          end

          context('user is prosecutor') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :prosecutor) }

            it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
          end

          context('user is greff_co') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :greff_co) }

            it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
          end

          context('user is greff_crpc') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :greff_crpc) }

            it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
          end

          context('user is greff_ca') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :greff_ca) }

            it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
          end

          context('user is dir_greff_bex') do
            let(:user) { create(:user, :in_organization, type: :tj, role: :dir_greff_bex) }

            it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
          end
        end
      end
      context('user is jap') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :jap) }

        it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is greff_sap') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :greff_sap) }

        it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is dir_greff_sap') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :dir_greff_sap) }

        it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
      end

      context('user is secretary_court') do
        let(:user) { create(:user, :in_organization, type: :tj, role: :secretary_court) }

        it { is_expected.to forbid_action(:no_divestment_or_convokable_nonetheless) }
      end
    end
  end

  context 'for an admin' do
    let(:user) { build(:user, :in_organization, role: 'admin') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    subject { ConvictPolicy.new(user, convict) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to permit_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization) }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to forbid_action(:unarchive) }
      end
    end
  end

  context 'for a local_admin' do
    let(:user) { build(:user, :in_organization, role: 'local_admin') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to permit_action(:self_assign) }
    it { is_expected.to permit_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to permit_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization) }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to forbid_action(:unarchive) }
      end
    end
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'prosecutor') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to permit_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to permit_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to permit_action(:unarchive) }
      end
    end
  end

  context 'for a jap user' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'jap') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to forbid_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to forbid_action(:unarchive) }
      end
    end
  end

  context 'for a court secretary' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'secretary_court') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to permit_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to forbid_action(:unarchive) }
      end
    end
  end

  context 'for a dir_greff_bex user' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'dir_greff_bex') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to permit_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to permit_action(:unarchive) }
      end
    end
  end

  context 'for a bex user' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'bex') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to permit_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to permit_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to permit_action(:unarchive) }
      end
    end
  end

  context 'for a greff_co user' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'greff_co') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to permit_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to permit_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to permit_action(:unarchive) }
      end
    end
  end

  context 'for a dir_greff_sap user' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'dir_greff_sap') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to forbid_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to forbid_action(:unarchive) }
      end
    end
  end

  context 'for a greff_sap user' do
    let(:user) { build(:user, :in_organization, type: 'tj', role: 'greff_sap') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to permit_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'tj') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to forbid_action(:unarchive) }
      end
    end
  end

  context 'for a cpip user' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'cpip') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to permit_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to permit_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to forbid_action(:unarchive) }
      end
    end
  end

  context 'for a educator user' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'educator') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to forbid_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to forbid_action(:unarchive) }
      end
    end
  end

  context 'for a psychologist user' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'psychologist') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to forbid_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to forbid_action(:unarchive) }
      end
    end
  end

  context 'for a overseer user' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'overseer') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to forbid_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to forbid_action(:unarchive) }
      end
    end
  end

  context 'for a dpip user' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'dpip') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to permit_action(:self_assign) }
    it { is_expected.to permit_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to permit_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to forbid_action(:unarchive) }
      end
    end
  end

  context 'for a secretary_spip user' do
    let(:user) { build(:user, :in_organization, type: 'spip', role: 'secretary_spip') }
    let(:convict) { build(:convict, organizations: [user.organization]) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to forbid_action(:unarchive) }
    it { is_expected.to forbid_action(:self_assign) }
    it { is_expected.to forbid_action(:unassign) }

    context 'for a discarded convict' do
      let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [user.organization]) }

      it { is_expected.to permit_action(:unarchive) }
    end

    context 'for a convict from another organization' do
      let(:organization) { build(:organization, organization_type: 'spip') }
      let(:convict) { build(:convict, organizations: [organization]) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:archive) }
      it { is_expected.to forbid_action(:unarchive) }
      it { is_expected.to forbid_action(:self_assign) }
      it { is_expected.to forbid_action(:unassign) }

      context 'for a discarded convict' do
        let(:convict) { build(:convict, discarded_at: Time.zone.now, organizations: [organization]) }

        it { is_expected.to forbid_action(:unarchive) }
      end
    end
  end
end
