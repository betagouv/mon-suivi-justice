require 'rails_helper'

RSpec.describe SecurityCharterAcceptancePolicy do
  subject { SecurityCharterAcceptancePolicy.new(user, :security_charter_acceptance) }

  context 'for a user who has not accepted the security charter' do
    let(:user) { build(:user, role: 'admin', security_charter_accepted_at: nil) }

    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
  end

  context 'for a user who has accepted the security charter' do
    let(:user) { build(:user, role: 'admin', security_charter_accepted_at: Time.zone.now - 1.minute) }

    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:create) }
  end
end
