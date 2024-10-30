class BrevoAdapter
  include DeploymentEnvironment

  def initialize
    SibApiV3Sdk.configure do |config|
      config.api_key['api-key'] = ENV.fetch('SIB_API_KEY', nil)
      config.api_key['partner-key'] = ENV.fetch('SIB_API_KEY', nil)
    end

    @client = SibApiV3Sdk::ContactsApi.new
  end

  def user_exists_in_brevo?(email)
    contact = @client.get_contact_info(email)
    true if contact && contact.email == email
  rescue SibApiV3Sdk::ApiError => e
    return false if e.code == 404

    raise e.message
  end

  # rubocop:disable Metrics/AbcSize
  def create_contact_for_user(user)
    return log_event('create_contact_for_user', user) unless real_production?

    create_contact_data = {
      email: user.email,
      attributes: {
        'ROLE' => user.role,
        'SERVICE' => user.organization.name,
        'PRENOM' => user.first_name,
        'NOM' => user.last_name
      }
    }

    create_contact_data[:listIds] = [ENV.fetch('BREVO_PROD_LIST_ID', 10).to_i]
    create_contact = SibApiV3Sdk::CreateContact.new(create_contact_data)

    begin
      @client.create_contact(create_contact)
    rescue SibApiV3Sdk::ApiError => e
      error_response = JSON.parse(e.response_body)
      raise unless error_response['code'] == 'duplicate_parameter'

      update_user_contact(user)
    end
  end

  def update_user_contact(user)
    return log_event('update_user_contact', user) unless real_production?

    identifier = user.email

    update_contact_data = {
      attributes: {
        'ROLE' => user.role,
        'SERVICE' => user.organization.name,
        'PRENOM' => user.first_name,
        'NOM' => user.last_name
      }
    }

    update_contact = SibApiV3Sdk::UpdateContact.new(update_contact_data)
    begin
      @client.update_contact(identifier, update_contact)
    rescue SibApiV3Sdk::ApiError => e
      error_response = JSON.parse(e.response_body)
      raise unless contact_not_found_error?(error_response)

      create_contact_for_user(user)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def delete_user_contact(user_email)
    return log_event('delete_user_contact', user_email) unless real_production?

    @client.delete_contact(user_email)
  rescue SibApiV3Sdk::ApiError => e
    error_response = JSON.parse(e.response_body)
    raise unless contact_not_found_error?(error_response)
  end

  private

  def contact_not_found_error?(error_response)
    error_response['code'] == 'document_not_found'
  end

  def log_event(event, user_or_email)
    Rails.logger.info("BrevoAdapter: Exécution de '#{event}' pour #{user_or_email.inspect} hors production.")
  end
end
