class SteeringController < ApplicationController
  before_action :authenticate_user!

  def steering
    authorize :steering, :steering?

    @global = DataCollector.new.perform
    @local = []

    Organization.all.each do |orga|
      @local << DataCollector.new(organization_id: orga.id).perform
    end
  end
end
