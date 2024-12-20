require 'rails_helper'

RSpec.describe DivestmentStalledService do
  describe '#call' do
    let(:organization) { instance_double('Organization') }
    let(:convict) do
      instance_double('Convict', archived?: false, no_future_appointments_outside_organization_and_links?: false)
    end
    let(:divestment) { instance_double('Divestment', convict:, organization:) }
    let(:organization_divestment) { instance_double('OrganizationDivestment', divestment:) }
    let(:organization_divestment2) { instance_double('OrganizationDivestment', divestment:) }
    let(:state_service) { instance_double('DivestmentStateService', accept: nil) }

    before do
      allow(OrganizationDivestment).to receive(:old_pending).and_return([organization_divestment,
                                                                         organization_divestment2])
      allow(DivestmentStateService).to receive(:new).with(organization_divestment, nil).and_return(state_service)
      allow(DivestmentStateService).to receive(:new).with(organization_divestment2, nil).and_return(state_service)

      allow(organization_divestment).to receive(:convict).and_return(convict)
      allow(organization_divestment2).to receive(:convict).and_return(convict)
    end

    context 'when convict is divestmentable' do
      it 'calls accept on DivestmentStateService' do
        allow(convict).to receive_messages(archived?: true)
        expect(state_service).to receive(:accept)
        DivestmentStalledService.new.call
      end
      it 'calls accept on DivestmentStateService' do
        allow(convict).to receive_messages(no_future_appointments_outside_organization_and_links?: true)
        expect(state_service).to receive(:accept)
        DivestmentStalledService.new.call
      end
    end

    context 'when convict is not divestmentable' do
      it 'does not call accept on DivestmentStateService' do
        allow(convict).to receive_messages(archived?: false)
        expect(state_service).not_to receive(:accept)
        DivestmentStalledService.new.call
      end
      it 'does not call accept on DivestmentStateService' do
        allow(convict).to receive_messages(no_future_appointments_outside_organization_and_links?: false)
        expect(state_service).not_to receive(:accept)
        DivestmentStalledService.new.call
      end
      it 'does not call accept on DivestmentStateService' do
        expect(state_service).not_to receive(:accept)
        DivestmentStalledService.new.call
      end
    end
  end
end
