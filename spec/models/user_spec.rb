require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user, :in_organization ) }

  it { should belong_to(:organization) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) }

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
        secretary_spip: 16,
        greff_tpe: 17,
        greff_crpc: 18,
        greff_ca: 19
      }
    )
  }

  describe '#set_default_role' do
    let(:organization) { create(:organization, organization_type: 'tj') }

    it 'sets the default role if role is blank' do
      user = User.new(organization: organization, email: 'admin@example.com', password: '1mot2passeSecurise!', password_confirmation: '1mot2passeSecurise!', first_name: 'Kevin', last_name: 'McCallister')
      expect(user).to be_valid
      expect(user.role).to eq('greff_sap')
    end

    it 'does not change the role if role is already present' do
      user = User.new(organization: organization, email: 'admin@example.com', password: '1mot2passeSecurise!', password_confirmation: '1mot2passeSecurise!', role: :admin, first_name: 'Kevin', last_name: 'McCallister')
      expect(user).to be_valid
      expect(user.role).to eq('admin')
    end
  end
end
