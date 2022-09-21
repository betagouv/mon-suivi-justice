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
end
