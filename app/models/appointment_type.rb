class AppointmentType < ApplicationRecord
  has_paper_trail

  has_many :notification_types, inverse_of: :appointment_type, dependent: :destroy
  has_many :slot_types, inverse_of: :appointment_type, dependent: :destroy

  has_many :place_appointment_types, dependent: :destroy
  has_many :places, through: :place_appointment_types

  accepts_nested_attributes_for :notification_types
  accepts_nested_attributes_for :slot_types, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true

  def summon_notif
    notification_types.find_by(role: :summon)
  end

  def reminder_notif
    notification_types.find_by(role: :reminder)
  end

  def cancelation_notif
    notification_types.find_by(role: :cancelation)
  end

  def no_show_notif
    notification_types.find_by(role: :no_show)
  end
end
