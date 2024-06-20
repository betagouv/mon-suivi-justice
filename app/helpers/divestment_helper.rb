module DivestmentHelper
  def badge_class(state)
    case state
    when 'accepted', 'auto_accepted'
      'fr-badge--success'
    when 'ignored'
      'fr-badge--new'
    when 'refused'
      'fr-badge--error'
    else
      ''
    end
  end

  def divestment_state_badge(state, human_state_name)
    content_tag(:p, human_state_name, class: "fr-badge fr-my-0-5v fr-badge--no-icon #{badge_class(state)} hyphens-auto")
  end
end
