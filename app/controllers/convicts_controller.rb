class ConvictsController < ApplicationController
  before_action :authenticate_user!

  def index
    @convicts = Convict.all
  end
end
