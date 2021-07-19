class Convict < ApplicationRecord
  has_paper_trail

  has_many :appointments, dependent: :destroy
  attr_accessor :place_id

  validates :first_name, :last_name, :title, presence: true

  validates :phone, format: { with: Phone::REGEX,
                              message: I18n.t('activerecord.errors.phone_format') }, allow_blank: true

  validate :phone_situation

  enum title: %i[male female]

  def name
    "#{last_name.upcase} #{first_name.capitalize}"
  end

  private

  def phone_situation
    return if phone.present? || refused_phone? || no_phone?

    errors.add(:phone, 'Téléphone manquant')
  end
end
