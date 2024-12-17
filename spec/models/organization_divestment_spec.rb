require 'rails_helper'

RSpec.describe OrganizationDivestment, type: :model do
  describe('old_pending') do
    let(:organization) { create(:organization, organization_type: 'spip') }
    let(:user) { create(:user, role: 'secretary_spip', organization:) }
    let(:old_pending_divestment) { create(:divestment, created_at: 10.days.ago, user:) }
    let(:pending_divestment) { create(:divestment, created_at: 9.days.ago, user:) }
    let(:accepted_divestment) { create(:divestment, created_at: 12.days.ago, state: :accepted, user:) }

    let!(:pending_od) do
      create(:organization_divestment, created_at: 9.days.ago, divestment: pending_divestment, organization:)
    end

    context 'one organization divestment accepted and one pending for more than 10 days' do
      let(:spip) { create(:organization, organization_type: 'spip') }
      let!(:old_accepted_od) do
        create(:organization_divestment, created_at: 10.days.ago, divestment: old_pending_divestment,
                                         organization: spip, state: :accepted)
      end
      let(:tj) { create(:organization, organization_type: 'tj') }
      let!(:old_pending_od) do
        create(:organization_divestment, created_at: 10.days.ago, divestment: old_pending_divestment, organization: tj,
                                         state: :pending)
      end
      it 'should return only the pending one' do
        expected = [old_pending_od]
        actual = OrganizationDivestment.old_pending

        expect(actual).to match_array(expected)
      end
    end

    context 'divestment is accepted' do
      let!(:old_pending_od) do
        create(:organization_divestment, state: :pending, created_at: 12.days.ago, divestment: accepted_divestment,
                                         organization:)
      end

      it 'should return an empty array' do
        expected = []
        actual = OrganizationDivestment.old_pending

        expect(actual).to match_array(expected)
      end
    end

    context 'created 9 days and 23 hours ago' do
      let(:old_pending_divestment) { create(:divestment, created_at: 10.days.ago + 1.hours, user:) }

      let(:tj) { create(:organization, organization_type: 'tj') }
      let!(:old_pending_od) do
        create(:organization_divestment, created_at: 10.days.ago + 1.hour, divestment: old_pending_divestment,
                                         organization: tj, state: :pending)
      end
      it 'should only considere the day part' do
        expected = [old_pending_od]
        actual = OrganizationDivestment.old_pending

        expect(actual).to match_array(expected)
      end
    end
  end
end
