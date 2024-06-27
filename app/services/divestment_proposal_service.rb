class DivestmentProposalService
  def initialize(duplicate_convicts, current_organization)
    @duplicate_convicts = duplicate_convicts
    @current_organization = current_organization
  end

  def call
    @duplicate_convicts.map do |duplicate_convict|
      show_divestment_button, duplicate_alert, duplicate_alert_details = handle_convict(duplicate_convict)

      {
        convict: duplicate_convict,
        show_button: show_divestment_button,
        alert: duplicate_alert,
        alert_details: duplicate_alert_details
      }
    end
  end

  private

  def handle_convict(duplicate_convict)
    show_divestment_button = true
    duplicate_alert = ''
    duplicate_alert_details = ''

    if duplicate_convict&.organizations&.include?(@current_organization)
      show_divestment_button = false
      org_names = org_names_with_custom_label(duplicate_convict,
                                              I18n.t('organization_divestment.alerts.your_organization'))
      duplicate_alert = format_duplicate_alert_string(duplicate_convict, org_names)
    else
      pending_divestment = duplicate_convict.divestments.find_by(state: 'pending')
      future_appointments = duplicate_convict.future_appointments

      show_divestment_button = pending_divestment.nil? && future_appointments.empty?
      duplicate_alert, duplicate_alert_details = other_org_alert(duplicate_convict, pending_divestment,
                                                                 future_appointments)
    end

    [show_divestment_button, duplicate_alert, duplicate_alert_details]
  end

  def org_names_with_custom_label(duplicate_convict, custom_label)
    duplicate_convict.organizations.map do |org|
      org == @current_organization ? custom_label : org.name
    end
  end

  def format_duplicate_alert_string(duplicate_convict, org_names)
    if org_names.length <= 1
      return "#{duplicate_convict.name} né le #{duplicate_convict.date_of_birth.to_fs} suivi par #{org_names.first}"
    end

    last = org_names.pop
    I18n.t('organization_divestment.alerts.convict_details',
           name: duplicate_convict.name,
           org_names: org_names.join(', '),
           date_of_birth: duplicate_convict.date_of_birth.to_fs,
           last:)
  end

  def other_org_alert(duplicate_convict, pending_divestment, future_appointments)
    duplicate_alert_details = ''
    org_names = formatted_organization_names_and_phones(duplicate_convict)
    duplicate_alert = format_duplicate_alert_string(duplicate_convict, org_names)

    if pending_divestment.present?
      organization_name = pending_divestment.organization.name
      duplicate_alert_details = I18n.t('organization_divestment.alerts.duplicate_alert_details', organization_name:)
    elsif future_appointments.any?
      unique_org_names = future_appointments.map { |appointment| appointment.organization.name }.uniq
      org_names_string = unique_org_names.join(', ')
      duplicate_alert_details = I18n.t('organization_divestment.alerts.pending_appointments_alert',
                                       org_names: org_names_string)
    end

    [duplicate_alert, duplicate_alert_details]
  end

  def formatted_organization_names_and_phones(duplicate_convict)
    duplicate_convict.organizations.map do |org|
      name_and_phone = org.name
      # [OPTIMIZE] org.places.first n'est pas fiable. Rajouter un boolean sur le lieu pour savoir si c'est le lieu
      # principal ou un téléphone directement sur le service
      name_and_phone += " (#{org.places.first&.phone})" if org.places.first&.phone.present?
      name_and_phone
    end
  end
end
