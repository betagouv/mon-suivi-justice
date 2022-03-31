module MonSuiviJusticePublicApi
  class Base
    class << self
      BASE_URL = ENV['MSJ_API_URL']
      USERNAME = ENV['MSJ_API_USERNAME']
      PASSWORD = ENV['MSJ_API_PASSWORD']

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
          raise "Error while fetching data from #{CONNECTOR} API"
        end
      end
    end
  end
end
