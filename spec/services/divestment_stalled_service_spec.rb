require 'rails_helper'

RSpec.describe DivestmentStalledService do
  describe '#call' do
    let(:convict) { instance_double("Convict", archived?: false, last_appointment_at_least_3_months_old?: false) }
    let(:divestment) { instance_double("Divestment", convict: convict) }
    let(:organization_divestment) { instance_double("OrganizationDivestment", divestment: divestment) }
    let(:state_service) { instance_double("DivestmentStateService", accept: nil, ignore: nil) }

    before do
      allow(OrganizationDivestment).to receive(:old_pending).and_return([organization_divestment])
      allow(DivestmentStateService).to receive(:new).with(organization_divestment, nil).and_return(state_service)

      allow(organization_divestment).to receive(:convict).and_return(convict)
    end

    context 'when convict is divestmentable' do 
      it 'calls accept on DivestmentStateService' do
        allow(convict).to receive_messages(archived?: true)
        expect(state_service).to receive(:accept)
        DivestmentStalledService.new.call
      end
      it 'calls accept on DivestmentStateService' do
        allow(convict).to receive_messages(last_appointment_at_least_3_months_old?: true)
        expect(state_service).to receive(:accept)
        DivestmentStalledService.new.call
      end
    end

    context 'when convict is not divestmentable' do
      it 'calls ignore on DivestmentStateService' do
        expect(state_service).to receive(:ignore)
        DivestmentStalledService.new.call
      end
    end
  end
end
