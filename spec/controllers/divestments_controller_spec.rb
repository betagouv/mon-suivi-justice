require 'rails_helper'

RSpec.describe DivestmentsController, type: :controller do
  describe '#create' do
    let(:user) { create(:user, :in_organization, role: 'cpip') }
    let(:convict) { create(:convict) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'when convict exists' do
      it 'delegates divestment creation to DivestmentCreatorService service' do
        allow(Convict).to receive(:find_by).with(id: convict.id.to_s).and_return(convict)
        expect(DivestmentCreatorService).to receive(:new).with(convict, user).and_call_original
        post :create, params: { convict_id: convict.id }
      end
    end

    context 'when convict does not exist' do
      it 'redirects to convicts path with an alert' do
        allow(Convict).to receive(:find_by).with(id: 'undefined').and_return(nil)
        post :create, params: { convict_id: 'undefined' }
        expect(response).to redirect_to(convicts_path)
        expect(flash[:alert]).to be_present
      end
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
