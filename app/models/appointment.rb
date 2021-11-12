class Appointment < ApplicationRecord
  has_paper_trail

  belongs_to :convict
  belongs_to :slot

  has_many :notifications, dependent: :destroy
  has_many :history_items, dependent: :destroy

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

  scope :in_organization, lambda { |organization|
    joins(slot: { agenda: :place }).where(slots: { agendas: { places: { organization: organization } } })
  }

  scope :active, -> { where.not(state: 'canceled') }

  def in_the_past?
    slot.date <= Date.today
  end

  def summon_notif
    notifications.find_by(role: :summon)
  end

  def reminder_notif
    notifications.find_by(role: :reminder)
  end

  def cancelation_notif
    notifications.find_by(role: :cancelation)
  end

  def no_show_notif
    notifications.find_by(role: :no_show)
  end

  def reschedule_notif
    notifications.find_by(role: :reschedule)
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

    state :excused do
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

    event :excuse do
      transition booked: :excused
    end

    after_transition do |appointment, transition|
      HistoryItem.create!(
        convict: appointment.convict,
        appointment: appointment,
        category: 'appointment',
        event: "#{transition.event}_appointment".to_sym
      )
    end

    after_transition on: :book do |appointment, transition|
      appointment.slot.increment!(:used_capacity, 1)
      if appointment.slot.full?
        appointment.slot.update(available: false)
      end

      appointment.transaction do
        NotificationFactory.perform(appointment)
        if appointment.convict.phone?
          send_sms = ActiveModel::Type::Boolean.new.cast(transition&.args&.first&.dig(:send_notification))
          appointment.summon_notif.send_now! if send_sms
          appointment.reminder_notif.program!
        end
      end
    end

    after_transition on: :cancel do |appointment, transition|
      if appointment.reminder_notif.programmed?
        appointment.reminder_notif.cancel!
      end
      send_sms = ActiveModel::Type::Boolean.new.cast(transition&.args&.first&.dig(:send_notification))
      appointment.cancelation_notif.send_now! if send_sms
    end

    after_transition on: :miss do |appointment, transition|
      send_sms = ActiveModel::Type::Boolean.new.cast(transition&.args&.first&.dig(:send_notification))
      appointment.no_show_notif&.send_now! if send_sms
    end
  end
end
