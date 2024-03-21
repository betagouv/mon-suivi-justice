require 'rails_helper'

describe Organizations::StatisticPolicy do
  subject { Organizations::StatisticPolicy.new(user, organization) }

  let(:organization) { build(:organization) }

  context 'for a user who has not accepted the security charter' do
    let(:user) { build(:user, role: 'admin', security_charter_accepted_at: nil) }

    it { is_expected.to forbid_action(:index) }
  end

  context 'for an admin' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'admin') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'admin', organization:) }

      it { is_expected.to permit_action(:index) }
    end
  end

  context 'for a local admin' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'local_admin') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'local_admin', organization:) }

      it { is_expected.to permit_action(:index) }
    end
  end

  context 'for a prosecutor' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'prosecutor') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'prosecutor', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a jap' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'jap') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'jap', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a secretary_court' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'secretary_court') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'secretary_court', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a dir_greff_bex' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'dir_greff_bex') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'dir_greff_bex', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a bex' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'bex') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'bex', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a greff_co' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'greff_co') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'greff_co', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a dir_greff_sap' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'dir_greff_sap') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'dir_greff_sap', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a greff_sap' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'greff_sap') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'greff_sap', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a cpip' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'cpip') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'cpip', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a educator' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'educator') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'educator', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a psychologist' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'psychologist') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'psychologist', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a overseer' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'overseer') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'overseer', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a dpip' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'dpip') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'dpip', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end

  context 'for a secretary_spip' do
    context 'who is not part of the organization' do
      let(:user) { build(:user, role: 'secretary_spip') }

      it { is_expected.to forbid_action(:index) }
    end

    context 'who is part of the organization' do
      let(:user) { build(:user, role: 'secretary_spip', organization:) }

      it { is_expected.to forbid_action(:index) }
    end
  end
end
