require 'rails_helper'

RSpec.describe AppointmentsBookingsController, type: :controller do
  describe 'GET #load_places' do
    let(:spip1) { create(:organization, name: 'SPIP 1', organization_type: 'spip') }
    let(:spip2) { create(:organization, name: 'SPIP 2', organization_type: 'spip') }
    let(:tj) { create(:organization, name: 'TJ', organization_type: 'tj', spips: [spip1]) }
    let(:user) { create(:user, organization: spip1, role: 'cpip') }
    let(:convict) { create(:convict, organizations: [spip1, spip2, tj]) }
    let(:appointment_type) { create(:appointment_type) }
    let!(:place1) do
      create(:place, organization: spip1, appointment_types: [appointment_type], name: 'place for spip1')
    end
    let!(:place2) { create(:place, organization: tj, appointment_types: [appointment_type], name: 'place for tj') }
    let!(:place3) do
      create(:place, organization: spip2, appointment_types: [appointment_type], name: 'place for spip2')
    end

    before do
      sign_in user
      # Set up any other necessary stubs or mocks
    end

    context 'when convict belongs to multiple organizations' do
      it 'loads the places related to user organization' do
        get :load_places, xhr: true, params: { convict_id: convict.id, apt_type_id: appointment_type.id }

        expect(assigns(:places)).to match_array([place1])
      end

      context 'bex user not in an inter ressort organization' do
        let(:user) { create(:user, organization: tj, role: 'bex') }

        it 'loads all places in jurisdiction' do
          get :load_places, xhr: true, params: { convict_id: convict.id, apt_type_id: appointment_type.id }

          expect(assigns(:places)).to match_array([place1, place2])
        end
      end

      context 'bex user is in an inter ressort organization' do
        let(:tj) { create(:organization, name: 'TJ', organization_type: 'tj', spips: [spip1], use_inter_ressort: true) }
        let(:user) { create(:user, organization: tj, role: 'bex') }

        it 'loads all places related to the convict organizations' do
          get :load_places, xhr: true, params: { convict_id: convict.id, apt_type_id: appointment_type.id }

          expect(assigns(:places)).to match_array([place1, place2, place3])
        end
      end
    end
  end
end
