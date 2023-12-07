require 'rails_helper'

RSpec.describe Organization, type: :model do
  it { should validate_presence_of(:name) }
  it { should have_many(:users).dependent(:destroy) }
  it { should have_many(:places).dependent(:destroy) }
  it { should have_many(:notification_types).dependent(:destroy) }
  it { should have_many(:areas_organizations_mappings).dependent(:destroy) }
  it { should have_many(:departments).through(:areas_organizations_mappings) }
  it { should have_many(:jurisdictions).through(:areas_organizations_mappings) }

  it { should define_enum_for(:organization_type).with_values({ spip: 0, tj: 1 }) }
  it { should validate_presence_of(:organization_type) }

  describe 'destruction with dependent associations' do
    let!(:organization) { create(:organization, tjs: [create(:organization, organization_type: 'tj')]) }
    let!(:convict) { create(:convict, organizations: [organization], creating_organization: organization) }

    before do
      create(:user, organization:)
      create(:place, organization:)
      create(:notification_type, organization:)
      create(:appointment, creating_organization: organization)
      create(:extra_field, name: 'Extra field A', organization:, data_type: 'text',
                           scope: 'appointment_create', appointment_types: [create(:appointment_type)])
    end

    it 'can be destroyed along with its dependencies' do
      expect { organization.destroy }.to change(Organization, :count).by(-1)
      expect(User.where(organization_id: organization.id)).to be_empty
      expect(Place.where(organization_id: organization.id)).to be_empty
      expect(NotificationType.where(organization_id: organization.id)).to be_empty
      expect(Appointment.where(creating_organization: organization.id)).to be_empty
      expect(ExtraField.where(organization_id: organization.id)).to be_empty
      convict.reload
      expect(convict.creating_organization).to be_nil
      expect(convict.organizations).to be_empty
    end
  end
end
