module Organizations
  class StatisticsController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize current_organization, policy_class: Organizations::StatisticPolicy
    end
  end
end
