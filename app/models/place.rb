class Place < ApplicationRecord
  validates :name, :adress, presence: true

  validates :phone, format: { with: /[0-9]{2}[0-9]{2}[0-9]{2}[0-9]{2}[0-9]{2}/,
                              message: I18n.t('activerecord.errors.phone_format') }, allow_blank: true
end
