require 'administrate/custom_dashboard'

class ImportConvictDashboard < Administrate::CustomDashboard
  resource 'Import probationnaire' # used by administrate in the views

  def show_search_bar
    false
  end
end
