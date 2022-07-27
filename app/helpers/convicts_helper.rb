module ConvictsHelper
  def selected_cpip_for(convict, current_user)
    if current_user.cpip?
      convict.user || current_user
    else
      convict.user
    end
  end

  def can_be_linked_to_user?(convict, current_user)
    (current_user.cpip? || current_user.dpip?) && convict.present? && convict.cpip.nil?
  end
end
