class Place < ApplicationRecord
  has_paper_trail

  validates :name, :adress, :place_type, :phone, presence: true

  validates :phone, format: { with: /[0-9]{2}[0-9]{2}[0-9]{2}[0-9]{2}[0-9]{2}/,
                              message: I18n.t('activerecord.errors.phone_format') }, allow_blank: true

  enum place_type: %i[spip sap]
end
