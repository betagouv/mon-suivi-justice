require 'rails_helper'

describe ConvictInvitationPolicy do
  subject { ConvictInvitationPolicy.new(user, convict) }

  context 'for a user who has not accepted the security charter' do
    let(:user) { build(:user, role: 'admin', security_charter_accepted_at: nil) }
    let(:convict) { build(:convict) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'for an admin' do
    let(:user) { build(:user, role: 'admin') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to permit_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to permit_action(:create) }
    end
  end

  context 'for a local_admin tj' do
    let(:organization) { create(:organization, organization_type: 'tj') }
    let(:user) { build(:user, role: 'local_admin', organization:) }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for a local_admin spip' do
    let(:organization) { create(:organization, organization_type: 'spip') }
    let(:user) { build(:user, role: 'local_admin', organization:) }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to permit_action(:create) }
    end

    context 'when the convict is persisted and belongs to the user\'s organization' do
      let(:convict) { build(:convict, organizations: [user.organization]) }

      it { is_expected.to permit_action(:create) }
    end
  end

  context 'for a prosecutor' do
    let(:user) { build(:user, role: 'prosecutor') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for a jap user' do
    let(:user) { build(:user, role: 'jap') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for a court secretary' do
    let(:user) { build(:user, role: 'secretary_court') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for a dir_greff_bex user' do
    let(:user) { build(:user, role: 'dir_greff_bex') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for a bex user' do
    let(:user) { build(:user, role: 'bex') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for a greff_co user' do
    let(:user) { build(:user, role: 'greff_co') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for a dir_greff_sap user' do
    let(:user) { build(:user, role: 'dir_greff_sap') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for a greff_sap user' do
    let(:user) { build(:user, role: 'greff_sap') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for a cpip user' do
    let(:user) { create(:user, :in_organization, role: 'cpip') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to permit_action(:create) }
    end

    context 'when the convict is persisted and belongs to the user\'s organization' do
      let(:convict) { build(:convict, user:) }

      it { is_expected.to permit_action(:create) }
    end
  end

  context 'for a educator user' do
    let(:user) { build(:user, role: 'educator') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for a psychologist user' do
    let(:user) { build(:user, role: 'psychologist') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for a overseer user' do
    let(:user) { build(:user, role: 'overseer') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  context 'for a dpip user' do
    let(:user) { build(:user, :in_organization, role: 'dpip') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to permit_action(:create) }
    end

    context 'when the convict is persisted and belongs to the user\'s organization' do
      let(:convict) { build(:convict, organizations: [user.organization]) }

      it { is_expected.to permit_action(:create) }
    end
  end

  context 'for a secretary_spip user' do
    let(:user) { build(:user, role: 'secretary_spip') }

    context 'when the convict is persisted' do
      let(:convict) { create(:convict) }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when the convict is not persisted' do
      let(:convict) { build(:convict) }

      it { is_expected.to forbid_action(:create) }
    end
  end
end
