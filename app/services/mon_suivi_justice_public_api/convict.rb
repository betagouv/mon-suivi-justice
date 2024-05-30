module MonSuiviJusticePublicApi
  class Convict < Base
    class << self
      def update_phone(params = {})
        connection.patch("#{BASE_URL}/api/users/update-phone", params.to_json,
                         'Content-Type': 'application/json')
      end

      def delete(convict)
        connection.delete("#{BASE_URL}/api/users/#{convict.id}", 'Content-Type': 'application/json')
      end
    end
  end
end
