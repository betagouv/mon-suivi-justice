module ConvictsHelper
  def selected_cpip_for(convict, current_user)
    if current_user.cpip?
      convict.user || current_user
    else
      convict.user
    end
  end
end
