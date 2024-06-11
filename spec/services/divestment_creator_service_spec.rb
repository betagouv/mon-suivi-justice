# spec/services/divestment_creator_spec.rb
require 'rails_helper'

RSpec.describe DivestmentCreatorService do
  let(:user) { create(:user, :in_organization, role: 'cpip') }
  let(:convict) { create(:convict) }
  let(:unsaved_divestment) { create(:divestment, convict:, user:, organization: user.organization) }

  subject(:service) { DivestmentCreatorService.new(convict, user, unsaved_divestment) }

  describe '#call' do
    before do
      allow(convict).to receive(:discarded?).and_return(false)
      allow(convict).to receive(:last_appointment_at_least_6_months_old?).and_return(false)
    end
    context 'when organizations have local admins' do
      before do
        create_list(:organization, 2, convicts: [convict])
      end

      it 'creates organization divestments with pending state' do
        convict.reload
        convict.organizations.each do |org|
          create(:user, role: 'local_admin', organization: org)
        end

        expect { service.call }.to change { OrganizationDivestment.where(state: 'pending').count }.by(3)
      end
    end

    context 'when organizations do not have local admins' do
      before do
        create_list(:organization, 2, convicts: [convict])
      end

      it 'creates organization divestments with ignored state' do
        convict.reload
        expect { service.call }.to change { OrganizationDivestment.where(state: 'ignored').count }.by(3)
      end
    end

    context 'when organizations are SPIP and TJS' do
      let(:tj) { create(:organization, organization_type: :tj) }
      let(:spip) do
        spip = build(:organization, organization_type: :spip)
        spip.tjs = [tj]
        spip.save
        spip
      end

      let(:convict) { create(:convict, organizations: [tj, spip]) }

      it 'creates organization divestments with auto_accepted state for spip if tj' do
        service.call
        expect(service.divestment.organization_divestments.count).to eq(2)
        expect(service.divestment.organization_divestments.find_by(organization: spip).state).to eq('auto_accepted')
        expect(service.divestment.organization_divestments.find_by(organization: tj).state).to eq('ignored')
      end
    end

    context 'when the convict is discarded' do
      before do
        allow(convict).to receive(:discarded?).and_return(true)
      end

      it 'sets divestment state to accepted' do
        service.call
        divestment = Divestment.last
        expect(divestment.state).to eq('auto_accepted')
      end
    end

    context 'when the last appointment is at least 6 months old' do
      before do
        allow(convict).to receive(:discarded?).and_return(false)
        allow(convict).to receive(:last_appointment_at_least_6_months_old?).and_return(true)
      end
      it 'sets divestment state to accepted' do
        service.call
        divestment = Divestment.last
        expect(divestment.state).to eq('auto_accepted')
      end
    end

    context 'when the convict is not discarded and last appointment is less than 6 months old' do
      before do
        allow(convict).to receive(:discarded?).and_return(false)
        allow(convict).to receive(:last_appointment_at_least_6_months_old?).and_return(false)
      end

      it 'sets divestment state to pending' do
        service.call
        divestment = Divestment.last
        expect(divestment.state).to eq('pending')
      end
    end
  end
end
