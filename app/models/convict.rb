class Convict < ApplicationRecord
  include NormalizedPhone
  has_paper_trail

  has_many :appointments, dependent: :destroy
  attr_accessor :place_id

  validates :first_name, :last_name, :title, presence: true
  validates :phone, presence: true, unless: proc { refused_phone? || no_phone? }
  validate :mobile_phone_number

  enum title: %i[male female]

  def name
    "#{last_name.upcase} #{first_name.capitalize}"
  end

  def profile_path
    Rails.application.routes.url_helpers.convict_path(id)
  end

  def booked_appointments
    appointments.where(state: 'booked')
  end

  def passed_appointments
    appointments.joins(:slot)
                .where(state: 'booked')
                .where('slots.date': ..Date.today)
  end

  def mobile_phone_number
    errors.add(:phone, 'Numéro de téléphone portable requis.') if phone && !phone.start_with?('+336', '+337')
  end
end
