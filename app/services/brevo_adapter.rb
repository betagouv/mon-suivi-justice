class BrevoAdapter
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

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Layout/LineLength
  def create_contact_for_user(user)
    create_contact_data = {
      email: user.email,
      attributes: {
        'ROLE' => user.role,
        'SERVICE' => user.organization.name,
        'PRENOM' => user.first_name,
        'NOM' => user.last_name
      }
    }

    create_contact_data[:listIds] = [ENV.fetch('BREVO_TEST_LIST_ID', 9).to_i] unless Rails.env.production?
    create_contact = SibApiV3Sdk::CreateContact.new(create_contact_data)

    begin
      @client.create_contact(create_contact)
    rescue SibApiV3Sdk::ApiError => e
      error_response = JSON.parse(e.response_body)
      raise unless error_response['code'] == 'duplicate_parameter' && error_response['message'] == 'Contact already exist'

      update_user_contact(user)
    end
  end

  def update_user_contact(user)
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
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def delete_user_contact(user_email)
    @client.delete_contact(user_email)
  rescue SibApiV3Sdk::ApiError => e
    error_response = JSON.parse(e.response_body)
    raise unless contact_not_found_error?(error_response)
  end
  # rubocop:enable Layout/LineLength

  private

  def contact_not_found_error?(error_response)
    error_response['code'] == 'document_not_found' && error_response['message'] == 'Contact does not exist'
  end
end
