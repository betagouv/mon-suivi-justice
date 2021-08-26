class Place < ApplicationRecord
  include NormalizedPhone
  has_paper_trail

  validates :name, :adress, :place_type, :phone, presence: true

  enum place_type: %i[spip sap]

  has_many :agendas, dependent: :destroy
  accepts_nested_attributes_for :agendas, reject_if: :all_blank, allow_destroy: true
end
