class SlotTypesController < ApplicationController
  before_action :authenticate_user!

  def index
    @slot_types = SlotTypes.all.page params[:page]
    authorize @slot_types
  end
end
