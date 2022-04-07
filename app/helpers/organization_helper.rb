module OrganizationHelper
  def form_organization_type
    Organization.organization_types.map do |k, _v|
      [I18n.t("activerecord.attributes.organization.organization_types.#{k}"), k]
    end.sort_by(&:last)
  end
end
