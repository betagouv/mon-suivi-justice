class PlaceTransfert < ActiveRecord::Base
  belongs_to :new_place, class_name: 'Place'
  belongs_to :old_place, class_name: 'Place'
  enum status: { tranfert_pending: 0, transfert_done: 1 }

  validates :date, presence: true
  validates :date, uniqueness: { scope: %i[new_place_id old_place_id] }
end
