module OrganizationDivestmentHelper
  def comment_text(comment)
    return comment if comment.present?

    'décision prise sans commentaire'
  end

  def organization_divestment_state_badge(organization_divestment)
    od_id = organization_divestment.id
    content_tag(:p, organization_divestment.organization_name,
                class: "fr-my-0-5v fr-badge fr-badge--no-icon #{badge_class(organization_divestment.state)}",
                aria: { describedby: "tooltip-od-#{od_id}" },
                id: "link-od-#{od_id}")
  end

  def organization_divestment_tooltip(organization_divestment)
    content_tag(:span, comment_text(organization_divestment.comment),
                class: "fr-tooltip fr-placement",
                id: "tooltip-od-#{organization_divestment.id}",
                role: "tooltip",
                aria: { hidden: true })
  end
end
