class AppointmentType < ApplicationRecord
  has_many :notification_types, inverse_of: :appointment_type
  has_many :slot_types, inverse_of: :appointment_type

  accepts_nested_attributes_for :notification_types
  accepts_nested_attributes_for :slot_types, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true

  def summon_notif
    notification_types.where(role: :summon).first
  end

  def reminder_notif
    notification_types.where(role: :reminder).first
  end
end
