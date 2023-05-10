module OrganizationHelper
  FRENCH_TIMEZONES = [
    { id: 'Europe/Paris', label: 'France Métropolitaine' },
    { id: 'Indian/Mayotte', label: 'Mayotte' },
    { id: 'Europe/Samara', label: 'La Réunion' },
    { id: 'Pacific/Noumea', label: 'Nouvelle-Calédonie' },
    { id: 'Pacific/Tarawa', label: 'Wallis et Futuna' },
    { id: 'Pacific/Honolulu', label: 'Polynésie française - îles Australes / Société / Tuamotu' },
    { id: 'Pacific/Marquesas', label: 'Polynésie française - îles Marquises' },
    { id: 'Pacific/Gambier', label: 'Polynésie française - îles Gambier' },
    { id: 'America/Puerto_Rico', label: 'Guadeloupe / Martinique / St Martin / St Barthélemy' },
    { id: 'America/Argentina/Cordoba', label: 'Guyane' },
    { id: 'America/Miquelon', label: 'St Pierre et Miquelon' }
  ].freeze

  def time_zones_for_select
    FRENCH_TIMEZONES.map do |tz|
      data = TZInfo::Timezone.get(tz[:id])
      ["#{formatted_offset(data)} - #{tz[:label]}", data.name]
    end
  end

  def formatted_offset(data)
    offset = offset_in_hours(data)
    sign = offset.positive? ? '+' : '-'
    hour = offset.abs.to_i.to_s.rjust(2, '0')

    minutes = (offset.modulo(1) * 60).to_i.to_s.rjust(2, '0')
    "UTC #{sign} #{hour}:#{minutes}"
  end

  def offset_in_hours(time_zone)
    time_zone.current_period.offset.utc_total_offset.to_f / 3600.0
  end

  def form_organization_type
    Organization.organization_types.map do |k, _v|
      [I18n.t("activerecord.attributes.organization.organization_types.#{k}"), k]
    end.sort_by(&:last)
  end

  def orga_for_user
    return Organization.all if current_user.admin?

    [current_user.organization]
  end

  def assignable_user_in_organization
    organization = current_user.organization
    organization_users = organization.users
    assignable_users = organization_users
                       .select(&:can_have_appointments_assigned?)
                       .reject { |user| user == current_user }
                       .sort_by(&:last_name)

    if current_user.can_have_appointments_assigned?
      assignable_users.unshift(current_user)
    else
      assignable_users
    end
  end
end
