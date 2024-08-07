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
    return Organization.all.order(:name) if current_user.admin?

    [current_user.organization]
  end

  def selectable_organizations_for_update
    return Organization.all.order(:name) if current_user.admin?

    @user.headquarter&.organizations
  end

  def switch_organization_submit_text(user)
    if user.admin?
      I18n.t('home.select_organization.admin')
    else
      I18n.t('home.select_organization.default')
    end
  end
end
