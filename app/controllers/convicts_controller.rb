class ConvictsController < ApplicationController
  before_action :authenticate_user!

  def index
    @convicts = Convict.all
  end

  def destroy
    @convict = Convict.find(params[:id])
    @convict.destroy
    redirect_to convicts_path
  end
end
