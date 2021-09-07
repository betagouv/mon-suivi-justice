class TemporaryLandingsController < ApplicationController
  layout 'application'

  skip_after_action :verify_authorized

  def landing; end
end
