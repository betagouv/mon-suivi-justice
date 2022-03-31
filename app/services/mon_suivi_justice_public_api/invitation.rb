module MonSuiviJusticePublicApi
  class Invitation < Base
    class << self
      def create(params = {})
        connection.post("#{BASE_URL}/sms_invitations", params.to_json, 'Content-Type': 'application/json')
      end
    end
  end
end
