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

  scope :for_a_month, lambda { |date = Date.today|
    joins(:slot).where('extract(month from slots.date) = ?', date.month)
  }

  def summon_notif
    notifications.find_by(role: :summon)
  end

  def reminder_notif
    notifications.find_by(role: :reminder)
  end

  def cancelation_notif
    notifications.find_by(role: :cancelation)
  end

  state_machine initial: :created do
    state :created do
    end

    state :booked do
    end

    state :canceled do
    end

    state :fulfiled do
    end

    state :no_show do
    end

    event :book do
      transition created: :booked
    end

    event :cancel do
      transition booked: :canceled
    end

    event :fulfil do
      transition booked: :fulfiled
    end

    event :miss do
      transition booked: :no_show
    end

    after_transition on: :book do |appointment|
      appointment.slot.increment!(:used_capacity, 1)
      if appointment.slot.full?
        appointment.slot.update(available: false)
      end

      if appointment.convict.phone?
        appointment.transaction do
          NotificationFactory.perform(appointment)

          appointment.summon_notif.send_now!
          appointment.reminder_notif.program!
        end
      end
    end

    after_transition on: :cancel do |appointment|
      appointment.reminder_notif.cancel!
      appointment.cancelation_notif.send_now!
    end
  end
end
