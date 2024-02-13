module MonSuiviJusticePublicApi
  class Invitation < Base
    class << self
      def create(params = {})
        connection.post("#{BASE_URL}/api/users/invite", params.to_json, 'Content-Type': 'application/json')
      end
    end
  end
end
