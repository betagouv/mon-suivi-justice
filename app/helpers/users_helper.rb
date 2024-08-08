module UsersHelper
  def available_user_roles
    if current_user.admin?
      User::ORDERED_ROLES
    elsif current_user.work_at_tj?
      [:local_admin] + User::ORDERED_TJ_ROLES
    elsif current_user.work_at_spip?
      [:local_admin] + User::ORDERED_SPIP_ROLES
    end
  end

  def current_user?(user)
    current_user == user
  end

  def access_advanced_nav?
    policy(:appointment_type).index? ||
      policy(:organization).index? ||
      policy(:place).index? ||
      policy(:user).index? ||
      policy(:slot).index? ||
      policy(:organization_divestment).index?
  end

  def places_options_for_select(places)
    places.map do |place|
      label = place.discarded_at ? "#{place.name} (Archivé)" : place.name
      [label, place.id]
    end
  end
end
