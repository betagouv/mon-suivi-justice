require 'administrate/custom_dashboard'

class PublicPageDashboard < Administrate::CustomDashboard
  resource 'PublicPage' # used by administrate in the views

  def show_search_bar
    false
  end
end
