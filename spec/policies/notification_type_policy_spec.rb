require 'rails_helper'

describe NotificationTypePolicy do
  subject { described_class.new(user, notification_type) }

  let(:organization_type) { :tj }
  let(:user) { create(:user, :in_organization, type: organization_type, role: user_role) }
  let(:organization) { user.organization }
  let(:is_default) { false }
  let(:still_default) { false }
  let(:notification_type) { create(:notification_type, still_default:, is_default:, organization:) }

  RSpec.shared_examples 'forbidden update' do
    it { is_expected.to forbid_action(:update) }
  end

  RSpec.shared_examples 'permitted update' do
    it { is_expected.to permit_action(:update) }
  end

  context 'user did not accept cgu' do
    let(:user) { create(:user, :in_organization, type: :tj, role: :admin, security_charter_accepted_at: nil) }
    it_behaves_like 'forbidden update'
  end

  context 'notification type constraints' do
    context 'notification type is default' do
      let(:user_role) { :admin }
      let(:is_default) { true }
      let(:organization) { nil }
      it_behaves_like 'forbidden update'
    end

    context 'notification type is still default' do
      let(:user_role) { :admin }
      let(:still_default) { true }
      it_behaves_like 'forbidden update'
    end
  end

  # Role-based tests
  User.roles.each_key do |role|
    context "user is #{role}" do
      let(:user_role) { role }

      let(:organization_type) { 'spip' } if User.spip_role?(role)

      case role
      when 'admin'
        it_behaves_like 'permitted update'
      else
        it_behaves_like 'forbidden update'
      end
    end
  end
end
