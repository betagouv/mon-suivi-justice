class Appointment < ApplicationRecord
  has_paper_trail

  belongs_to :appointment_type
  belongs_to :convict
  belongs_to :slot

  has_many :notifications, dependent: :destroy

  attr_accessor :place_id, :agenda_id

  enum origin_department: %i[bex gref_co pr]

  scope :for_today, lambda {
    joins(:slot).where('slots.date' => Date.today)
                .order('slots.starting_time asc')
  }

  scope :for_a_date, ->(date = Date.today) { joins(:slot).where('slots.date' => date) }

  def summon_notif
    notifications.find_by(role: :summon)
  end

  def reminder_notif
    notifications.find_by(role: :reminder)
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
      if appointment.slot.full?
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
