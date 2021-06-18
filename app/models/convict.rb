class Convict < ApplicationRecord
  has_many :appointments, dependent: :destroy
  attr_accessor :place_id

  validates :first_name, :last_name, presence: true

  validates :phone, presence: true,
                    format: { with: /[0-9]{2}[0-9]{2}[0-9]{2}[0-9]{2}[0-9]{2}/,
                              message: I18n.t('activerecord.errors.phone_format') }

  def name
    "#{last_name.upcase} #{first_name}"
  end
end
