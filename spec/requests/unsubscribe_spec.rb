require 'rails_helper'

RSpec.describe "Unsubscribes", type: :request do
  describe "GET /stop_sms" do
    it "returns http success" do
      get "/unsubscribe/stop_sms"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /refuse_phone" do
    it "returns http success" do
      get "/unsubscribe/refuse_phone"
      expect(response).to have_http_status(:success)
    end
  end

end
