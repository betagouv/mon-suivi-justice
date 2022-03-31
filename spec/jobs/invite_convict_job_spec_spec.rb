require 'rails_helper'

RSpec.describe InviteConvictJob, type: :job do
  with_env('MSJ_API_URL', 'https://www.msj_public.com')
  with_env('MSJ_API_USERNAME', 'username')
  with_env('MSJ_API_PASSWORD', 'password')

  describe '#perform' do
    let(:convict) { create(:convict, id: 1, phone: "+33666666666") }

    before do
      stub_request(:post, "https://www.msj_public.com/sms_invitations")
      InviteConvictJob.perform_now(convict.id)
    end

    it 'calls the public API with the correct body' do
      assert_requested :post, "https://www.msj_public.com/sms_invitations",
                        headers: {'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ='}, body: {phone: "+33666666666", msj_id: 1}.to_json, times: 1
    end
  end
end
