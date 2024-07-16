require 'rails_helper'

RSpec.describe DivestmentStalledService do
  describe '#call' do
    let(:convict) { instance_double('Convict', archived?: false, last_appointment_at_least_3_months_old?: false) }
    let(:divestment) { instance_double('Divestment', convict:) }
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

      allow(UserMailer).to receive(:admin_divestment_action_needed).and_call_original
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
      it 'does not send email to the admin' do
        allow(convict).to receive_messages(last_appointment_at_least_3_months_old?: true)
        DivestmentStalledService.new.call
        expect(UserMailer).not_to have_received(:admin_divestment_action_needed)
      end
    end

    context 'when convict is not divestmentable' do
      it 'sends email to the admin' do
        DivestmentStalledService.new.call
        expect(UserMailer).to have_received(:admin_divestment_action_needed).once
      end
    end
  end
end
