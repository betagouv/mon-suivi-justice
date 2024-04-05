require 'rails_helper'

RSpec.describe DivestmentStateService do
  let(:tj) { create(:organization, name: 'TJ', organization_type: :tj) }
  let(:spip) { create(:organization, name: 'SPIP', organization_type: :spip) }
  let(:admin) { create(:user, organization: tj, role: 'local_admin') }
  let(:spip_target) { create(:organization, name: 'SPIP target', organization_type: :spip) }
  let(:tj_target) do
    tj = build(:organization, name: 'TJ target', organization_type: :tj)
    tj.spips = [spip_target]
    tj.save
    tj
  end
  let(:user) { create(:user, organization: tj_target, role: 'bex') }
  let(:convict) { create(:convict, organizations: [tj, spip, tj_target, spip_target]) }
  let(:divestment) { create(:divestment, state: 'pending', convict:, user:, organization: tj_target) }
  let(:tj_organization_divestment) { create(:organization_divestment, divestment:, organization: tj, state: :pending) }
  let(:spip_divestment_state) { :auto_accepted }
  let!(:spip_organization_divestment) { create(:organization_divestment, divestment:, organization: spip, state: spip_divestment_state, comment: "auto_accepted") }

  subject(:service) { DivestmentStateService.new(tj_organization_divestment, admin)}

  describe 'accept divestment' do
    context 'not all organization divestments are accepted' do
      let(:spip_divestment_state) { :pending }

      it 'does not change the divestment state' do
        service.update('accept')
        divestment.reload
        tj_organization_divestment.reload

        expect(divestment.state).to eq('pending')
        expect(tj_organization_divestment.state).to eq('accepted')
      end
    end
    context 'all organization divestments are accepted' do
      let(:spip_divestment_state) { :auto_accepted }

      it 'change the divestment state' do
        service.update('accept')
        divestment.reload
        tj_organization_divestment.reload
        convict.reload

        expect(tj_organization_divestment.state).to eq('accepted')
        expect(divestment.state).to eq('accepted')
        expect(divestment.decision_date).to eq(Date.today)
        expect(convict.organizations).to match_array([tj_target, spip_target])
      end
    end
  end

  describe 'refuse divestment' do
    context 'other organization divestments are accepted' do
      let(:spip_divestment_state) { :auto_accepted }

      it 'change the divestment state' do
        service.update('refuse')
        tj_organization_divestment.reload
        convict.reload
        divestment.reload

        expect(divestment.refused?).to eq(true)
        expect(tj_organization_divestment.refused?).to eq(true)
        expect(divestment.decision_date).to eq(Date.today)
        expect(convict.organizations).to match_array([tj, spip])
      end
    end
  end
end