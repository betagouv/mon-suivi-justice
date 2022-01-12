class SteeringsController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :steering, :show?

    @global = DataCollector.new.perform
    @local = []

    Organization.all.each do |orga|
      @local << DataCollector.new(organization_id: orga.id).perform
    end
  end
end
