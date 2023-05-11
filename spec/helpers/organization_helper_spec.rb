require 'rails_helper'

describe OrganizationHelper do
  describe 'assignable_user_in_organization' do
    let!(:organization) { create(:organization, organization_type: :spip) }
    let!(:user) { create(:user, organization: organization, last_name: 'Ashe', role: :cpip) }
    let!(:user2) { create(:user, organization: organization, last_name: 'Bernard', role: :cpip) }
    let!(:user3) { create(:user, organization: organization, last_name: 'Non CPIP', role: :local_admin) }

    it 'returns the list of assignable users in the organization' do
      allow(helper).to receive(:current_user).and_return(user3)
      actual = helper.assignable_user_in_organization

      expect(actual).to eq([user, user2])
    end

    it 'the current user should be the firt in list' do
      allow(helper).to receive(:current_user).and_return(user2)
      actual = helper.assignable_user_in_organization
      expect(actual).to eq([user2, user])
    end
  end
end
