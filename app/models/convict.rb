class Convict < ApplicationRecord
  has_many :appointments, dependent: :destroy
  attr_accessor :place_id

  validates :first_name, :last_name, :title, presence: true

  validates :phone, format: { with: /[0-9]{2}[0-9]{2}[0-9]{2}[0-9]{2}[0-9]{2}/,
                              message: I18n.t('activerecord.errors.phone_format') }, allow_blank: true

  validate :phone_situation

  enum title: %i[male female]

  def phone_situation
    return unless phone.blank? && refused_phone.blank? && no_phone.blank?

    errors.add(:phone, 'Téléphone manquant')
  end

  def name
    "#{last_name.upcase} #{first_name}"
  end
end
