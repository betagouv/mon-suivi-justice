class DeletePlaceTransfertJob < ApplicationJob
  def perform
    # Find PlaceTransfert records with status "done" and a date older than 1 month
    place_transferts_to_delete = PlaceTransfert.transfert_done.where('date < ?', 1.month.ago)

    # Delete the found records
    place_transferts_to_delete.destroy_all
  end
end
