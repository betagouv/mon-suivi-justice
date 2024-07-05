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

  describe '.with_divestment_to_be_reminded' do
    let!(:organization1) { create(:organization, organization_type: :tj) }
    let!(:organization2) { create(:organization, organization_type: :spip) }
    let!(:organization3) { create(:organization, organization_type: :spip) }

    let(:convict) { create(:convict) }
    let(:organization) { create(:organization, organization_type: :tj) }
    let(:user) { create(:user, organization:, role: 'bex') }
    let!(:divestment) { create(:divestment, convict:, organization:, user:) }

    let!(:divestment1) do
      create(:organization_divestment, divestment:, organization: organization1, state: 'pending',
                                       last_reminder_email_at: nil)
    end
    let!(:divestment2) do
      create(:organization_divestment, divestment:, organization: organization1, state: 'pending',
                                       last_reminder_email_at: 6.days.ago)
    end
    let!(:divestment3) do
      create(:organization_divestment, divestment:, organization: organization2, state: 'pending',
                                       last_reminder_email_at: 4.days.ago)
    end
    let!(:divestment4) do
      create(:organization_divestment, divestment:, organization: organization3, state: 'accepted',
                                       last_reminder_email_at: nil)
    end

    it 'returns organizations with pending divestments and no reminder email or reminder email older than 5 days' do
      result = Organization.with_divestment_to_be_reminded

      expect(result).to include(organization1)
      expect(result).not_to include(organization2) # last_reminder_email_at is 4 days ago
      expect(result).not_to include(organization3) # state is 'accepted'
    end
  end
end
