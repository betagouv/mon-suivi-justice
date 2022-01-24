# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  invited_by_type        :string
#  last_name              :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("admin")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :bigint
#  organization_id        :bigint
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invited_by            (invited_by_type,invited_by_id)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_organization_id       (organization_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
require 'rails_helper'

RSpec.describe User, type: :model do
  it { should belong_to(:organization) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:role) }

  it {
    should define_enum_for(:role).with_values(
      {
        admin: 0,
        bex: 1,
        cpip: 2,
        local_admin: 4,
        prosecutor: 5,
        jap: 6,
        secretary_court: 7,
        dir_greff_bex: 8,
        greff_co: 9,
        dir_greff_sap: 10,
        greff_sap: 11,
        educator: 12,
        psychologist: 13,
        overseer: 14,
        dpip: 15,
        secretary_spip: 16
      }
    )
  }

  describe '.in_department' do
    it 'returns places scoped by department' do
      department1 = create :department, number: '01', name: 'Ain'

      organization1 = create :organization
      create :areas_organizations_mapping, organization: organization1, area: department1
      user1 = create :user, organization: organization1

      organization2 = create :organization
      create :areas_organizations_mapping, organization: organization2, area: department1
      user2 = create :user, organization: organization2

      department2 = create :department, number: '02', name: 'Aisne'

      organization3 = create :organization
      create :areas_organizations_mapping, organization: organization3, area: department2
      create :user, organization: organization3

      expect(User.in_department(department1)).to eq [user1, user2]
    end
  end
end
