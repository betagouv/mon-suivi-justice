class SlotTypesController < ApplicationController
  before_action :authenticate_user!

  def index
    @slot_types = SlotTypes.all
    authorize @slot_types
  end
end
