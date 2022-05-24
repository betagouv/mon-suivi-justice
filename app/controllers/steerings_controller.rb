class SteeringsController < ApplicationController
  before_action :authenticate_user!

  def user_app_stats
    authorize :steering, :user_app_stats?

    @global = DataCollector.new.perform
    @local = []

    Organization.all.each do |orga|
      @local << DataCollector.new(organization_id: orga.id).perform
    end
  end

  def convict_app_stats
    authorize :steering, :convict_app_stats?

    @invites = Convict.where(invitation_to_convict_interface_count: ..1).count
    @reminder = Convict.where(invitation_to_convict_interface_count: ..2).count
    @account_created = Convict.where.not(timestamp_convict_interface_creation: nil).count
  end
end
