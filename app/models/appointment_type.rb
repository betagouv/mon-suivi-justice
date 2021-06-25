class AppointmentType < ApplicationRecord
  has_many :notification_types, inverse_of: :appointment_type
  accepts_nested_attributes_for :notification_types

  validates :name, presence: true

  def summon_notif
    notification_types.where(role: :summon).first
  end

  def reminder_notif
    notification_types.where(role: :reminder).first
  end
end
