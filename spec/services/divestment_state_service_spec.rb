require 'rails_helper'

RSpec.describe DivestmentStateService do
  let(:tj) { create(:organization, name: 'TJ', organization_type: :tj) }
  let(:spip) { create(:organization, name: 'SPIP', organization_type: :spip) }
  let(:cpip) { create(:user, organization: spip, role: 'cpip') }
  let(:admin) { create(:user, organization: tj, role: 'local_admin') }
  let(:target_use_ir) { false }
  let(:spip_target) do
    create(:organization, name: 'SPIP target', organization_type: :spip, use_inter_ressort: target_use_ir)
  end
  let(:tj_target) do
    tj = build(:organization, name: 'TJ target', organization_type: :tj, use_inter_ressort: target_use_ir)
    tj.spips = [spip_target]
    tj.save
    tj
  end
  let(:city) { nil }
  let(:user) { create(:user, organization: tj_target, role: 'bex') }
  let(:convict) { create(:convict, organizations: [tj, spip, tj_target, spip_target], user: cpip, city:) }
  let(:divestment) { create(:divestment, state: 'pending', convict:, user:, organization: tj_target) }
  let(:tj_organization_divestment) { create(:organization_divestment, divestment:, organization: tj, state: :pending) }
  let(:spip_divestment_state) { :auto_accepted }
  let!(:spip_organization_divestment) do
    create(:organization_divestment, divestment:, organization: spip, state: spip_divestment_state,
                                     comment: 'auto_accepted')
  end

  subject(:service) { DivestmentStateService.new(tj_organization_divestment, admin) }

  describe 'accept divestment' do
    it 'handle comment' do
      service.accept('this is a comment')
      tj_organization_divestment.reload

      expect(tj_organization_divestment.comment).to eq('this is a comment')
    end

    context 'only 1 organization divestment with state ignored' do
      let(:admin) { create(:user, organization: spip, role: 'local_admin') }
      let(:convict) { create(:convict, organizations: [spip, tj_target, spip_target], user: cpip, city:) }
      let(:tj_organization_divestment) { nil }
      let(:spip_divestment_state) { :ignored }

      subject(:service) { DivestmentStateService.new(spip_organization_divestment, admin) }

      it 'change the divestment state' do
        service.accept
        divestment.reload
        spip_organization_divestment.reload
        convict.reload

        expect(spip_organization_divestment.state).to eq('accepted')
        expect(spip_organization_divestment.decision_date).to eq(Date.today)
        expect(divestment.state).to eq('accepted')
        expect(divestment.decision_date).to eq(Date.today)
        expect(convict.user).to be_nil
        expect(convict.organizations).to match_array([tj_target, spip_target])
      end
    end
    context 'not all organization divestments are accepted' do
      let(:spip_divestment_state) { :pending }

      it 'does not change the divestment state' do
        service.accept
        divestment.reload
        tj_organization_divestment.reload

        expect(divestment.state).to eq('pending')
        expect(tj_organization_divestment.decision_date).to eq(Date.today)
        expect(tj_organization_divestment.state).to eq('accepted')
      end
    end
    context 'all organization divestments are accepted' do
      let(:spip_divestment_state) { :auto_accepted }

      it 'change the divestment state' do
        service.accept
        divestment.reload
        tj_organization_divestment.reload
        convict.reload

        expect(tj_organization_divestment.state).to eq('accepted')
        expect(divestment.state).to eq('accepted')
        expect(tj_organization_divestment.decision_date).to eq(Date.today)
        expect(divestment.decision_date).to eq(Date.today)
        expect(convict.user).to be_nil
        expect(convict.organizations).to match_array([tj_target, spip_target])
      end

      context 'city' do
        let(:city) { create(:city) }
        before do
          service.accept
          divestment.reload
          convict.reload
        end
        context 'target use IR' do
          let(:target_use_ir) { true }
          it 'should keep the city' do
            expect(convict.city).to eq(city)
          end
        end
        context 'target dont use IR' do
          let(:target_use_ir) { false }
          it 'should remove the city' do
            expect(convict.city).to be_nil
          end
        end
      end
    end
  end
  describe 'ignore divestment' do
    context 'not all organization divestments are accepted' do
      let(:spip_divestment_state) { :pending }

      it 'does not change the divestment state' do
        service.ignore
        divestment.reload
        tj_organization_divestment.reload

        expect(divestment.state).to eq('pending')
        expect(tj_organization_divestment.state).to eq('ignored')
      end
    end
    context 'other organization divestments are accepted' do
      let(:spip_divestment_state) { :auto_accepted }

      it 'does not change the divestment state' do
        service.ignore
        divestment.reload
        tj_organization_divestment.reload
        convict.reload

        expect(tj_organization_divestment.state).to eq('ignored')
        expect(divestment.state).to eq('pending')
      end
    end
  end

  describe 'refuse divestment' do
    it 'handle comment' do
      service.refuse('this is a negative comment')
      tj_organization_divestment.reload

      expect(tj_organization_divestment.comment).to eq('this is a negative comment')
    end
    context 'other organization divestments are accepted' do
      let(:spip_divestment_state) { :auto_accepted }

      it 'change the divestment state' do
        service.refuse
        tj_organization_divestment.reload
        convict.reload
        divestment.reload

        expect(divestment.refused?).to eq(true)
        expect(tj_organization_divestment.refused?).to eq(true)
        expect(tj_organization_divestment.decision_date).to eq(Date.today)
        expect(divestment.decision_date).to eq(Date.today)
        expect(convict.organizations).to match_array([tj, spip])
      end
    end
    context 'other organization divestments are pending' do
      let(:spip_divestment_state) { :pending }

      it 'change the divestment state' do
        service.refuse
        tj_organization_divestment.reload
        convict.reload
        divestment.reload
        spip_organization_divestment.reload

        expect(divestment.refused?).to eq(true)
        expect(tj_organization_divestment.refused?).to eq(true)
        expect(tj_organization_divestment.decision_date).to eq(Date.today)
        expect(divestment.decision_date).to eq(Date.today)
        expect(convict.organizations).to match_array([tj, spip])
        expect(spip_organization_divestment.ignored?).to eq(true)
      end
    end
    context 'city' do
      let(:city) { create(:city) }
      before do
        service.refuse
        divestment.reload
        convict.reload
      end
      context 'target use IR' do
        let(:target_use_ir) { true }
        it 'should remove the city' do
          expect(convict.city).to be_nil
        end
      end
      context 'target dont use IR' do
        let(:target_use_ir) { false }
        it 'should keep the city' do
          expect(convict.city).to eq(city)
        end
      end
    end
  end
end
