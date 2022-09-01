module OrganizationHelper
  def form_organization_type
    Organization.organization_types.map do |k, _v|
      [I18n.t("activerecord.attributes.organization.organization_types.#{k}"), k]
    end.sort_by(&:last)
  end

  def time_zones_for_select
    # Toutes les zones, hors territoires autraux et ile clipperton
    tz_list = [
      TZInfo::Timezone.get('Europe/Paris'), # ETC +2
      TZInfo::Timezone.get('Pacific/Honolulu'), # ETC -10
      TZInfo::Timezone.get('Pacific/Marquesas'), # ETC -9:30
      TZInfo::Timezone.get('Pacific/Gambier'), # ETC -9
      TZInfo::Timezone.get('America/Puerto_Rico'), # ETC -4
      TZInfo::Timezone.get('America/Argentina/Cordoba'), # ETC -3
      TZInfo::Timezone.get('America/Miquelon'), # ETC -3 + DST
      TZInfo::Timezone.get('Indian/Mayotte'), # ETC +3
      TZInfo::Timezone.get('Europe/Samara'), # ETC +4
      TZInfo::Timezone.get('Pacific/Noumea'), # ETC +11
      TZInfo::Timezone.get('Pacific/Tarawa') # ETC +12
    ]

    tz_list.map { |tz| [ "#{offset_in_hours(tz)} - #{tz.name}", tz.name] }
  end

  def offset_in_hours(tz)
    (tz.current_period.offset.utc_total_offset).to_f / 3600.0
  end
end
