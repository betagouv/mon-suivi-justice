module ConvictsHelper
  def selected_cpip_for(convict, current_user)
    if current_user.cpip? || current_user.dpip?
      convict.user || current_user
    else
      convict.user
    end
  end

  def can_be_linked_to_user?(convict, current_user)
    current_user.can_follow_convict? && convict.present? && convict.cpip.nil?
  end

  def cpip_for_select(organization)
    User.in_organization(organization).where(role: %w[cpip dpip local_admin])
  end

  def ir_available_services(convict)
    convict.organizations.pluck(:name).join(', ')
  end

  def convict_attribute_name_and_value(convict, attribute)
    attribute_value = convict.send(attribute)
    human_attribute_name = Convict.human_attribute_name(attribute)
    return human_attribute_name unless attribute_value.present?

    "#{human_attribute_name} (#{attribute_value})"
  end
end
