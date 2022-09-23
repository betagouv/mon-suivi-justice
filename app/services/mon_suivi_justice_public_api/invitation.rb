module MonSuiviJusticePublicApi
  class Invitation < Base
    class << self
      def create(params = {})
        if ENV['APP'] == 'mon-suivi-justice-staging'
          connection.post("#{BASE_URL}/api/users/invite", params.to_json, 'Content-Type': 'application/json')
        else
          connection.post("#{BASE_URL}/sms_invitations", params.to_json, 'Content-Type': 'application/json')
        end
      end
    end
  end
end
