class DivestmentDecision
  attr_reader :show_divestment_button, :duplicate_alert

  def initialize(duplicate_convict, current_organization)
    @duplicate_convict = duplicate_convict
    @current_organization = current_organization
    @show_divestment_button = true
    @duplicate_alert = ''
  end

  def call
    if @duplicate_convict&.organizations&.include?(@current_organization)
      handle_duplicate_is_under_current_org
    else
      handle_duplicate_is_under_other_org
    end
    { show_button: @show_divestment_button, alert: @duplicate_alert }
  end

  private

  def handle_duplicate_is_under_current_org
    @show_divestment_button = false
    org_names = org_names_with_custom_label('votre propre service')
    @duplicate_alert = format_duplicate_alert_string(org_names)
  end

  def handle_duplicate_is_under_other_org
    pending_divestment = @duplicate_convict.divestments.find_by(state: 'pending')
    future_appointments = @duplicate_convict.future_appointments

    @show_divestment_button = pending_divestment.nil? && future_appointments.none?
    other_org_alert(pending_divestment)
  end

  def org_names_with_custom_label(custom_label)
    @duplicate_convict.organizations.map do |org|
      org == @current_organization ? custom_label : org.name
    end
  end

  def format_duplicate_alert_string(org_names)
    return org_names.first.to_s if org_names.length <= 1

    last = org_names.pop
    "#{@duplicate_convict.full_name} suivi par #{org_names.join(', ')} ainsi que #{last}"
  end

  def other_org_alert(pending_divestment)
    if pending_divestment.present?
      @duplicate_alert = "Le probationnaire #{@duplicate_convict.full_name} fait \
                          déjà l'objet d'une demande de dessaisissement \
                          de la part de #{pending_divestment.organization.name}."
    else
      org_names = formatted_organization_names_and_phones
      @duplicate_alert = format_duplicate_alert_string(org_names)
    end
  end

  def formatted_organization_names_and_phones
    @duplicate_convict.organizations.map do |org|
      name_and_phone = org.name
      name_and_phone += " (#{org.places.first&.phone})" if org.places.first&.phone.present?
      name_and_phone
    end
  end
end
