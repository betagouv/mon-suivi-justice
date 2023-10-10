class BrevoAdapter
  def initialize
    SibApiV3Sdk.configure do |config|
      config.api_key['api-key'] = ENV.fetch('SIB_API_KEY', nil)
      config.api_key['partner-key'] = ENV.fetch('SIB_API_KEY', nil)
    end

    @client = SibApiV3Sdk::ContactsApi.new
  end

  # rubocop:disable Metrics/MethodLength
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

    create_contact = SibApiV3Sdk::CreateContact.new(create_contact_data)

    begin
      @client.create_contact(create_contact)
    rescue SibApiV3Sdk::ApiError => e
      raise e.message
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
      raise e.message
    end
  end
  # rubocop:enable Metrics/MethodLength
end
