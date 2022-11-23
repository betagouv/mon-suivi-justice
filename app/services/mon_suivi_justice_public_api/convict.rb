module MonSuiviJusticePublicApi
  class Convict < Base
    class << self
      def update_phone(params = {})
        connection.patch("#{BASE_URL}/api/users/#{params[:msj_id]}/update-phone", params.to_json,
                         'Content-Type': 'application/json')
      end
    end
  end
end
