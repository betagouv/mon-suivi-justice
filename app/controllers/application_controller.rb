class ApplicationController < ActionController::Base
  include Pundit

  layout :layout_by_resource

  def layout_by_resource
    if devise_controller?
      "authentication"
    else
      "agent_interface"
    end
  end
end
