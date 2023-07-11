require 'administrate/custom_dashboard'

class ImportSrjDashboard < Administrate::CustomDashboard
  resource 'Import srj' # used by administrate in the views

  def show_search_bar
    false
  end
end
