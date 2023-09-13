require 'administrate/custom_dashboard'

class UserAlertDashboard < Administrate::CustomDashboard
  resource 'Alerte' # used by administrate in the views

  def show_search_bar
    false
  end
end
