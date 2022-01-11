class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def home
    @convicts = policy_scope(Convict.all)
    @stats = DataCollector.new.perform
  end
end
