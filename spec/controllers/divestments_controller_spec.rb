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

  describe '#update_convict_organizations' do
    let(:bex_user) { create(:user, :in_organization, role: 'bex') }
    let(:convict) { create(:convict) }
    let(:bex_organization) { bex_user.organization }

    before do
      allow(controller).to receive(:current_user).and_return(bex_user)
      allow(bex_user).to receive(:work_at_bex?).and_return(true)
      controller.send(:update_convict_organizations, convict)
    end

    it 'adds current user organizations to convict if user works at BEX' do
      expect(convict.organizations).to include(bex_organization)
    end
  end

  describe '#redirect_after_creation' do
    let(:convict) { create(:convict) }

    before do
      allow(controller).to receive(:new_appointment_path).and_return('/appointments/new')
      allow(controller).to receive(:convicts_path).and_return('/convicts')
      request.host = 'test.host'
    end

    context 'when current user works at BEX' do
      let(:bex_user) { create(:user, :in_organization, role: 'bex') }

      before do
        allow(controller).to receive(:current_user).and_return(bex_user)
        allow(bex_user).to receive(:work_at_bex?).and_return(true)
      end

      it 'redirects to new appointment path with convict id' do
        expect(controller).to receive(:redirect_to).with(new_appointment_path(convict_id: convict.id), anything)
        controller.send(:redirect_after_creation, convict)
      end
    end

    context 'when current user does not work at BEX' do
      let(:non_bex_user) { create(:user, :in_organization, role: 'cpip') }

      before do
        allow(controller).to receive(:current_user).and_return(non_bex_user)
        allow(non_bex_user).to receive(:work_at_bex?).and_return(false)
      end

      it 'redirects to convicts path' do
        expect(controller).to receive(:redirect_to).with(convicts_path, anything)
        controller.send(:redirect_after_creation, convict)
      end
    end
  end
end
