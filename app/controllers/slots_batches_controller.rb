class SlotsBatchesController < ApplicationController
  before_action :authenticate_user!

  def update
    slots = Slot.where(id: params[:slot_ids])
    slots.update_all(available: false)

    redirect_to slots_path

    authorize slots
  end
end
