module UsersHelper
  def available_user_roles
    if current_user.admin?
      ordered_user_roles
    else
      ordered_user_roles.reject { |role| role == 'admin' }
    end
  end

  def ordered_user_roles
    %w[
      admin
      local_admin
      jap
      bex
      prosecutor
      secretary_court
      dir_greff_bex
      greff_co
      greff_tpe
      greff_crpc
      greff_ca
      dir_greff_sap
      greff_sap
      dpip
      cpip
      secretary_spip
      educator
      psychologist
      overseer
    ]
  end

  def current_user?(user)
    current_user == user
  end

  def access_advanced_nav?
    policy(:appointment_type).index? ||
      policy(:organization).index? ||
      policy(:place).index? ||
      policy(:user).index? ||
      policy(:slot).index?
  end

  def places_options_for_select(user)
    Place.in_organization(user.organization).map do |place|
      label = place.discarded_at ? "#{place.name} (Archivé)" : place.name
      [label, place.id]
    end
  end
end
