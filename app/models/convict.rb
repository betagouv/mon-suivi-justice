class Convict < ApplicationRecord
  has_many :appointments, inverse_of: :convict
  validates :first_name, :last_name, presence: true

  validates :phone, presence: true,
                    format: { with: /[0-9]{2}[0-9]{2}[0-9]{2}[0-9]{2}[0-9]{2}/,
                              message: I18n.t('activerecord.errors.phone_format') }

  accepts_nested_attributes_for :appointments
end
