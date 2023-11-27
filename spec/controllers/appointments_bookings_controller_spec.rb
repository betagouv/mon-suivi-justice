require 'rails_helper'

RSpec.describe AppointmentsBookingsController, type: :controller do
  describe 'GET #load_places' do
    let(:spip1) { create(:organization, name: 'SPIP 1', organization_type: 'spip') }
    let(:spip2) { create(:organization, name: 'SPIP 2', organization_type: 'spip') }
    let(:user) { create(:user, organization: spip1) }
    let(:convict) { create(:convict, organizations: [spip1, spip2]) }
    let(:appointment_type) { create(:appointment_type) }
    let!(:place1) { create(:place, organization: spip1, appointment_types: [appointment_type]) }
    let!(:place2) { create(:place, organization: spip2, appointment_types: [appointment_type]) }

    before do
      sign_in user
      # Set up any other necessary stubs or mocks
    end

    context 'when convict belongs to multiple organizations' do
      it 'loads the places related to user organization' do
        get :load_places, xhr: true, params: { convict_id: convict.id, apt_type_id: appointment_type.id }

        expect(assigns(:places)).to eq([place1])
        # Further expectations regarding the contents of @places
      end
    end

    # Add more contexts as necessary for different test scenarios
  end
end
