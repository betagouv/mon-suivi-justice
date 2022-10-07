require 'administrate/custom_dashboard'

class SeedDashboard < Administrate::CustomDashboard
  resource 'Seed' # used by administrate in the views

  def show_search_bar
    false
  end
end
