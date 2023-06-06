class PlaceTransfert < ActiveRecord::Base
  belongs_to :new_place, class_name: 'Place'
  belongs_to :old_place, class_name: 'Place'
  enum status: { transfert_pending: 0, transfert_done: 1 }
  accepts_nested_attributes_for :new_place

  validates :date, presence: true
  validates :date, uniqueness: { scope: %i[new_place_id old_place_id] }
end
