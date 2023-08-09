class SteeringsController < ApplicationController
  before_action :authenticate_user!

  def user_app_stats
    authorize :steering, :user_app_stats?

    @global = DataCollector::User.new.perform
    @local = []

    Organization.all.each do |orga|
      @local << DataCollector::User.new(organization_id: orga.id).perform
    end
  end

  def convict_app_stats
    authorize :steering, :convict_app_stats?

    @invites = Convict.where(invitation_to_convict_interface_count: 1..).count
    @reminder = Convict.where(invitation_to_convict_interface_count: 2..).count
    @account_created = Convict.where.not(timestamp_convict_interface_creation: nil).count
  end

  def sda_stats
    authorize :steering, :sda_stats?

    @global = DataCollector::Sda.new.perform
    @local = []
    orgs_ids = [2, 3, 4, 6, 7]

    orgs_ids.each do |id|
      orga = Organization.find_by(id:)
      next if orga.nil?

      @local << DataCollector::Sda.new(organization_id: orga.id).perform
    end
  end
end
