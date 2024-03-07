require 'rails_helper'

describe PlacePolicy do
  subject { PlacePolicy.new(user, place) }

  let(:spip) { build(:organization, organization_type: 'spip') }
  let(:tj) { build(:organization, organization_type: 'tj', spips: [spip]) }
  let(:place) { build(:place, organization:) }

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
      it 'create' do
        expect(subject).to receive(:check_ownership?)
        subject.create?
      end
      it 'archive' do
        expect(subject).to receive(:check_ownership?)
        subject.archive?
      end
      it 'edit' do
        expect(subject).to receive(:check_ownership?)
        subject.edit?
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

  context 'scope' do
    subject { PlacePolicy::Scope.new(user, Place).resolve }
    let(:spip) { create(:organization, organization_type: 'spip') }
    let(:spip2) { create(:organization, organization_type: 'spip') }
    let(:tj) { create(:organization, organization_type: 'tj', spips: [spip]) }
    let(:rdv_suivi_jap) { build(:appointment_type, name: 'Convocation de suivi JAP') }
    let!(:place1) { create(:place, organization: tj, name: 'TJ Place', appointment_types: [rdv_suivi_jap]) }
    let(:rdv_suivi_spip) { build(:appointment_type, name: 'Convocation de suivi JAP') }
    let!(:place2) do
      create(:place, organization: spip, name: 'SPIP1 Place without ddse', appointment_types: [rdv_suivi_spip])
    end
    let!(:place3) { create(:place, organization: spip2, name: 'SPIP2 Place') }

    context 'bex' do
      context 'for a bex user' do
        let(:user) { build(:user, role: 'bex', organization: tj) }

        context 'no inter_ressort' do
          it 'returns only places in the jurisdiction' do
            expect(subject).to match_array([place1, place2])
          end
        end

        context 'inter_ressort' do
          let(:tj) { build(:organization, organization_type: 'tj', use_inter_ressort: true) }
          it 'returns all places' do
            expect(subject).to match_array([place1, place2, place3])
          end
        end
      end
      context 'for a prosecutor user' do
        let(:user) { build(:user, role: 'prosecutor', organization: tj) }

        context 'no inter_ressort' do
          it 'returns only places in the jurisdiction' do
            expect(subject).to match_array([place1, place2])
          end
        end

        context 'inter_ressort' do
          let(:tj) { build(:organization, organization_type: 'tj', use_inter_ressort: true) }
          it 'returns all places' do
            expect(subject).to match_array([place1, place2, place3])
          end
        end
      end
      context 'for a greff_crpc user' do
        let(:user) { build(:user, role: 'greff_crpc', organization: tj) }

        context 'no inter_ressort' do
          it 'returns only places in the jurisdiction' do
            expect(subject).to match_array([place1, place2])
          end
        end

        context 'inter_ressort' do
          let(:tj) { build(:organization, organization_type: 'tj', use_inter_ressort: true) }
          it 'returns all places' do
            expect(subject).to match_array([place1, place2, place3])
          end
        end
      end
      context 'for a greff_tpe user' do
        let(:user) { build(:user, role: 'greff_tpe', organization: tj) }

        context 'no inter_ressort' do
          it 'returns only places in the jurisdiction' do
            expect(subject).to match_array([place1, place2])
          end
        end

        context 'inter_ressort' do
          let(:tj) { build(:organization, organization_type: 'tj', use_inter_ressort: true) }
          it 'returns all places' do
            expect(subject).to match_array([place1, place2, place3])
          end
        end
      end
      context 'for a greff_ca user' do
        let(:user) { build(:user, role: 'greff_ca', organization: tj) }

        context 'no inter_ressort' do
          it 'returns only places in the jurisdiction' do
            expect(subject).to match_array([place1, place2])
          end
        end

        context 'inter_ressort' do
          let(:tj) { build(:organization, organization_type: 'tj', use_inter_ressort: true) }
          it 'returns all places' do
            expect(subject).to match_array([place1, place2, place3])
          end
        end
      end
      context 'for a greff_co user' do
        let(:user) { build(:user, role: 'greff_co', organization: tj) }

        context 'no inter_ressort' do
          it 'returns only places in the jurisdiction' do
            expect(subject).to match_array([place1, place2])
          end
        end

        context 'inter_ressort' do
          let(:tj) { build(:organization, organization_type: 'tj', use_inter_ressort: true) }
          it 'returns all places' do
            expect(subject).to match_array([place1, place2, place3])
          end
        end
      end

      context 'for a dir_greff_bex user' do
        let(:user) { build(:user, role: 'dir_greff_bex', organization: tj) }

        context 'no inter_ressort' do
          it 'returns only places in the jurisdiction' do
            expect(subject).to match_array([place1, place2])
          end
        end

        context 'inter_ressort' do
          let(:tj) { build(:organization, organization_type: 'tj', use_inter_ressort: true) }
          it 'returns all places' do
            expect(subject).to match_array([place1, place2, place3])
          end
        end
      end
    end

    context 'for a local_admin_tj user' do
      let(:user) { build(:user, role: 'local_admin', organization: tj) }
      it 'returns only places in the jurisdiction' do
        expect(subject).to match_array([place1, place2])
      end
    end

    context 'for an admin user' do
      let(:user) { build(:user, role: 'admin', organization: tj) }
      it 'returns only places in the jurisdiction' do
        expect(subject).to match_array([place1, place2])
      end
    end

    context 'for a local_admin_spip user' do
      let(:user) { build(:user, role: 'local_admin', organization: spip) }
      it 'returns only places in organization' do
        expect(subject).to match_array([place2])
      end
    end

    context 'for a cpip user' do
      let(:user) { build(:user, role: 'cpip', organization: spip) }
      it 'returns only places in organization' do
        expect(subject).to match_array([place2])
      end
    end

    context 'for a educator user' do
      let(:user) { build(:user, role: 'educator', organization: spip) }
      it 'returns only places in organization' do
        expect(subject).to match_array([place2])
      end
    end

    context 'for a psychologist user' do
      let(:user) { build(:user, role: 'psychologist', organization: spip) }
      it 'returns only places in organization' do
        expect(subject).to match_array([place2])
      end
    end

    context 'for a dpip user' do
      let(:user) { build(:user, role: 'dpip', organization: spip) }
      it 'returns only places in organization' do
        expect(subject).to match_array([place2])
      end
    end

    context 'for a overseer user' do
      let(:user) { build(:user, role: 'overseer', organization: spip) }
      it 'returns only places in organization' do
        expect(subject).to match_array([place2])
      end
    end

    context 'for a secretary_spip user' do
      let(:user) { build(:user, role: 'secretary_spip', organization: spip) }
      it 'returns only places in organization' do
        expect(subject).to match_array([place2])
      end
    end
    context 'sap' do
      let(:sap_ddse) { build(:appointment_type, name: 'SAP DDSE') }
      let!(:place4) { create(:place, organization: spip, appointment_types: [sap_ddse], name: 'SPIP1 Place with DDSE') }
      context 'for a jap user' do
        let(:user) { build(:user, role: 'jap', organization: tj) }
        it 'returns only places in organization' do
          expect(subject).to match_array([place1, place4])
        end
      end

      context 'for a greff_sap user' do
        let(:user) { build(:user, role: 'greff_sap', organization: tj) }
        it 'returns only places in organization' do
          expect(subject).to match_array([place1, place4])
        end
      end

      context 'for a dir_greff_sap user' do
        let(:user) { build(:user, role: 'dir_greff_sap', organization: tj) }
        it 'returns only places in organization' do
          expect(subject).to match_array([place1, place4])
        end
      end

      context 'secretary_court' do
        let(:user) { build(:user, role: 'secretary_court', organization: tj) }
        it 'returns only places in organization' do
          expect(subject).to match_array([place1, place4])
        end
      end
    end
  end

  context 'for a user who has not accepted the security charter' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'admin', organization:, security_charter_accepted_at: nil) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
  end

  context 'for an admin' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'admin', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
  end

  context 'for a local_admin' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'local_admin', organization:) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
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
  end

  context 'for a court secretary' do
    let(:organization) { tj }
    let(:user) { build(:user, role: 'secretary_court', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
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
  end

  context 'for a overseer user' do
    let(:organization) { spip }
    let(:user) { build(:user, role: 'overseer', organization:) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:update) }
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
  end
end
