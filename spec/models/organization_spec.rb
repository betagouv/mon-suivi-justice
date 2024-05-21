require 'rails_helper'

RSpec.describe Organization, type: :model do
  it { should validate_presence_of(:name) }
  it { should have_many(:users).dependent(:destroy) }
  it { should have_many(:places).dependent(:destroy) }
  it { should have_many(:notification_types).dependent(:destroy) }

  it { should define_enum_for(:organization_type).with_values({ spip: 0, tj: 1 }) }
  it { should validate_presence_of(:organization_type) }

  describe 'destruction with dependent associations' do
    let!(:organization) do
      create(:organization, organization_type: 'tj', spips: [create(:organization, organization_type: 'spip')])
    end
    let!(:convict) { create(:convict, organizations: [organization], creating_organization: organization) }

    before do
      create(:user, organization:)
      create(:place, organization:)
      create(:notification_type, organization:)
      create(:appointment, creating_organization: organization)
      create(:extra_field, name: 'Extra field A', organization:, data_type: 'text',
                           scope: 'appointment_create', appointment_types: [create(:appointment_type)])
    end
  end
end
