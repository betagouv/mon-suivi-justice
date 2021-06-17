class Appointment < ApplicationRecord
  belongs_to :appointment_type
  belongs_to :convict
  belongs_to :slot

  has_many :notifications, dependent: :destroy

  attr_accessor :place_id

  state_machine initial: :waiting do
    state :waiting do
    end

    state :booked do
    end

    event :book do
      transition waiting: :booked
    end

    after_transition on: :book do |appointment|
      appointment.slot.update(available: false)
      notif = Notification.create!(appointment_id: appointment.id)
      notif.send_now
    end
  end
end
