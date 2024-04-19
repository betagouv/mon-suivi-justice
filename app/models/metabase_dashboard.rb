class MetabaseDashboard
  def initialize(attributes)
    @service_id = attributes[:service_id]
    @dashboard_id = attributes[:dashboard_id]
    @metabase_site_url = 'https://msj-metabase.osc-secnum-fr1.scalingo.io'
    @metabase_secret_key = ENV.fetch('METABASE_SECRET_KEY', nil)
  end

  def iframe_url
    payload = {
      resource: { dashboard: @dashboard_id },
      params: {
        service_id: @service_id&.to_s
      },
      exp: Time.now.to_i + (60 * 10)
    }
    token = JWT.encode payload, @metabase_secret_key

    "#{@metabase_site_url}/embed/dashboard/#{token}#theme=transparent&bordered=false&titled=false"
  end
end
