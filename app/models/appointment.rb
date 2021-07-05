class Appointment < ApplicationRecord
  has_paper_trail

  belongs_to :appointment_type
  belongs_to :convict
  belongs_to :slot

  has_many :notifications, dependent: :destroy

  attr_accessor :place_id

  scope :for_today, lambda {
    joins(:slot).where('slots.date' => Date.today)
                .order('slots.starting_time asc')
  }

  def summon_notif
    notifications.where(role: :summon).first
  end

  def reminder_notif
    notifications.where(role: :reminder).first
  end

  state_machine initial: :waiting do
    state :waiting do
    end

    state :booked do
    end

    event :book do
      transition waiting: :booked
    end

    after_transition on: :book do |appointment|
      appointment.slot.increment!(:used_capacity, 1)
      if appointment.slot.used_capacity == appointment.slot.capacity
        appointment.slot.update(available: false)
      end

      if appointment.convict.phone?
        NotificationFactory.perform(appointment)

        appointment.summon_notif&.send_now
        appointment.reminder_notif&.send_later
      end
    end
  end
end
