module MonSuiviJusticePublicApi
  class Base
    class << self
      BASE_URL = ENV.fetch('MSJ_API_URL', nil)
      USERNAME = ENV.fetch('MSJ_API_USERNAME', nil)
      PASSWORD = ENV.fetch('MSJ_API_PASSWORD', nil)

      def connection
        Faraday.new { |conn| conn.request :authorization, :basic, USERNAME, PASSWORD }
      end

      def format_response(response)
        case response.status
        when 200
          JSON.parse(response.body, object_class: OpenStruct)
        when 401
          raise 'Unauthorized access'
        when 404
          nil
        else
          raise "Error while fetching data from #{BASE_URL} API"
        end
      end
    end
  end
end
