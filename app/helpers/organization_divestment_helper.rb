module OrganizationDivestmentHelper
  def organization_divestment_state_badge(organization_divestment)
    od_id = organization_divestment.id
    classes = "fr-my-0-5v fr-badge fr-badge--no-icon #{badge_class(organization_divestment.state)} hyphens-auto"
    content_tag(:p, organization_divestment.organization_name,
                class: classes,
                aria: { describedby: "tooltip-od-#{od_id}" },
                id: "link-od-#{od_id}")
  end

  def organization_divestment_tooltip(organization_divestment)
    return unless organization_divestment.comment.present?

    content_tag(:span, organization_divestment.comment,
                class: 'fr-tooltip fr-placement',
                id: "tooltip-od-#{organization_divestment.id}",
                role: 'tooltip',
                aria: { hidden: true })
  end
end
