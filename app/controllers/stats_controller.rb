class StatsController < ApplicationController
  skip_after_action :verify_authorized

  def secret_stats
  end
end
