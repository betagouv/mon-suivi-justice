require 'rails_helper'

RSpec.describe '/api/v1/convicts/:convict_id/invitation', type: :request do
  with_env('HTTP_BASIC_AUTH_USER', 'username')
  with_env('HTTP_BASIC_AUTH_PSWD', 'password')

  let(:do_request) { patch(path.to_s, headers:) }

  let(:convict) { create(:convict, id: 1, timestamp_convict_interface_creation: nil) }

  describe 'Patch' do
    let(:path) { "/api/v1/convicts/#{convict.id}/invitation" }

    before do
      do_request
    end

    context 'with the right api_key' do
      let(:headers) do
        { 'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials('username', 'password') }
      end

      let(:expected_response) do
        { 'error' => 'Not found' }
      end

      context 'basic call' do
        it 'renders a successful response' do
          expect(response).to be_successful
        end

        it 'has the right content' do
          expect(JSON.parse(response.body)['id']).to eq(1)
        end

        it 'updates the convict timestamp_convict_interface_creation' do
          convict.reload
          expect(convict.timestamp_convict_interface_creation).not_to be_nil
        end
      end

      context 'for a user who does not exist' do
        let(:path) { '/api/v1/convicts/10/invitation' }

        let(:expected_response) do
          { 'error' => 'Not found' }
        end

        it 'renders a successful response' do
          expect(response).to be_not_found
        end

        it 'has the right not found content' do
          expect(JSON.parse(response.body)).to match(expected_response)
        end
      end
    end

    context 'with the wrong api_key' do
      let(:headers) do
        { 'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials('mauvais', 'password') }
      end

      it 'renders a successful response with the wrong api_key' do
        expect(response).to be_unauthorized
      end
    end

    context 'without api_key' do
      let(:headers) { {} }

      it 'renders a successful response without api_key' do
        expect(response).to be_unauthorized
      end
    end
  end
end
