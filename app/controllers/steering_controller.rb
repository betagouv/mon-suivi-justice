class SteeringController < ApplicationController
  before_action :authenticate_user!

  def steering
    authorize :steering, :steering?
  end
end
