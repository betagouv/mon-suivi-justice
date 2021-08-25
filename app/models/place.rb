class Place < ApplicationRecord
  has_paper_trail

  # Phone attribute will be normalized to a +33... format BEFORE validation.
  phony_normalize :phone, default_country_code: 'FR'

  validates :name, :adress, :place_type, :phone, presence: true
  validates :phone, phony_plausible: true

  enum place_type: %i[spip sap]

  has_many :agendas, dependent: :destroy
  accepts_nested_attributes_for :agendas, reject_if: :all_blank, allow_destroy: true
end
