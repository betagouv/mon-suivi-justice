require 'rails_helper'

RSpec.describe DivestmentsController, type: :controller do
  let(:controller) { DivestmentsController.new }

  describe '#create_organization_divestments' do
    let(:user) { create(:user, :in_organization, role: 'cpip') }
    let(:convict) { create(:convict) }
    let(:divestment) { create(:divestment, convict:, user:) }
    let(:organization) { create(:organization, name: 'Organization', organization_type: 'spip') }

    before do
      create_list(:organization, 2, convicts: [convict])
      allow(controller).to receive(:current_user).and_return(create(:user, role: 'cpip', organization:))
    end

    context 'when organizations have local admins' do
      it 'creates organization divestments with ignored state' do
        convict.reload
        convict.organizations.each do |org|
          create(:user, role: 'local_admin', organization: org)
        end

        expect do
          controller.send(:create_organization_divestments, divestment, convict, 'pending')
        end.to change { OrganizationDivestment.where(state: 'pending').count }.by(3)
      end
    end

    context 'when organizations do not have local admins' do
      it 'creates organization divestments with ignored state' do
        convict.reload
        expect do
          controller.send(:create_organization_divestments, divestment, convict, 'pending')
        end.to change { OrganizationDivestment.where(state: 'ignored').count }.by(3)
      end
    end
  end

  describe '#divestment_state' do
    let(:convict) { instance_double('Convict') }

    context 'when the convict is discarded' do
      it 'returns validated' do
        allow(convict).to receive(:discarded?).and_return(true)
        allow(convict).to receive(:last_appointment_at_least_6_months_old?).and_return(false)
        expect(controller.send(:divestment_state, convict)).to eq('validated')
      end
    end

    context 'when the last appointment is at least 6 months old' do
      it 'returns validated' do
        allow(convict).to receive(:discarded?).and_return(false)
        allow(convict).to receive(:last_appointment_at_least_6_months_old?).and_return(true)
        expect(controller.send(:divestment_state, convict)).to eq('validated')
      end
    end

    context 'when the convict is not discarded and last appointment is less than 6 months old' do
      it 'returns pending' do
        allow(convict).to receive(:discarded?).and_return(false)
        allow(convict).to receive(:last_appointment_at_least_6_months_old?).and_return(false)
        expect(controller.send(:divestment_state, convict)).to eq('pending')
      end
    end
  end
end