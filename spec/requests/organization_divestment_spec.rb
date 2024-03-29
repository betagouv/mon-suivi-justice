require 'rails_helper'

RSpec.describe 'OrganizationDivestments', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/organization_divestment/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/organization_divestment/show'
      expect(response).to have_http_status(:success)
    end
  end
end
