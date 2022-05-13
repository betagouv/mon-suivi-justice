module MonSuiviJusticePublicApi
  class Convict < Base
    class << self
      def destroy(id)
        connection.delete("#{BASE_URL}/convict/#{id}", 'Content-Type': 'application/json')
      end
    end
  end
end
