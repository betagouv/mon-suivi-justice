class Appointment < ApplicationRecord
  has_paper_trail

  belongs_to :convict
  belongs_to :slot
  belongs_to :user, optional: true

  has_many :notifications, dependent: :destroy
  has_many :history_items, dependent: :destroy

  accepts_nested_attributes_for :slot

  delegate :date, :starting_time, :duration, :agenda, :appointment_type, to: :slot
  delegate :name, :share_address_to_convict, to: :appointment_type, prefix: true
  delegate :place, to: :agenda
  delegate :name, to: :agenda, prefix: true
  delegate :organization, to: :place
  delegate :name, :adress, :phone, :contact_email, :main_contact_method,
           to: :place, prefix: true
  delegate :name, to: :organization, prefix: true
  delegate :phone, to: :convict, prefix: true

  attr_accessor :place_id, :agenda_id, :user_is_cpip

  enum origin_department: {
    bex: 0,
    gref_co: 1,
    pr: 2,
    greff_tpe: 3,
    greff_crpc: 4,
    greff_ca: 5
  }

  scope :for_a_date, ->(date = Date.today) { joins(:slot).where('slots.date' => date) }

  scope :for_a_place, lambda { |place|
    joins(slot: { agenda: :place }).where(slots: { agendas: { places: place } })
  }

  scope :for_a_month, lambda { |date = Date.today|
    joins(:slot).where('extract(month from slots.date) = ?', date.month)
  }

  scope :in_organization, lambda { |organization|
    joins(slot: { agenda: :place }).where(slots: { agendas: { places: { organization: organization } } })
  }

  scope :in_department, lambda { |department|
    joins(convict: :areas_convicts_mappings)
      .where(convict: { areas_convicts_mappings: { area_type: 'Department', area_id: department.id } })
  }

  scope :active, -> { where.not(state: 'canceled') }

  validate :in_the_future, on: :create

  def in_the_future
    if slot.date.nil?
      errors.add(:base, I18n.t('activerecord.errors.models.appointment.attributes.date.blank'))
    elsif slot.date < Date.today
      errors.add(:base, I18n.t('activerecord.errors.models.appointment.attributes.date.past'))
    end
  end

  def in_the_past?
    date < Date.today || (date == Date.today && starting_time.strftime('%H:%M') <= Time.now.strftime('%H:%M'))
  end

  def datetime
    DateTime.new(date.year, date.month, date.day,
                 starting_time.hour, starting_time.min, starting_time.sec, starting_time.zone)
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

    event :rebook do
      transition %i[fulfiled no_show excused] => :booked
    end

    after_transition do |appointment, transition|
      event = "#{transition.event}_appointment".to_sym
      if HistoryItem.validate_event(event) == true
        HistoryItemFactory.perform(
          appointment: appointment,
          event: event,
          category: 'appointment'
        )
      end
    end

    after_transition on: :book do |appointment, transition|
      appointment.slot.increment!(:used_capacity, 1)
      appointment.slot.update(full: true) if appointment.slot.all_capacity_used?

      appointment.transaction do
        NotificationFactory.perform(appointment)
        appointment.summon_notif.send_now! if send_sms?(transition)
        appointment.reminder_notif.program!
      end
    end

    after_transition on: :cancel do |appointment, transition|
      appointment.slot.decrement!(:used_capacity, 1)
      appointment.slot.update(full: false) if appointment.slot.all_capacity_used? == false

      appointment.reminder_notif.cancel! if appointment.reminder_notif.programmed?

      if send_sms?(transition) && appointment.convict.phone.present?
        appointment.cancelation_notif.send_now!
      end
    end

    after_transition on: :miss do |appointment, transition|
      appointment.no_show_notif&.send_now! if send_sms?(transition)
    end

    before_transition on: :rebook do |appointment, _|
      previous_event = appointment.state_paths(from: :booked, to: appointment.state.to_sym)
                                  .find { |a| a.length == 1 }.first.event.to_s

      history_item = appointment.history_items.where(event: "#{previous_event}_appointment".to_sym)
                                .order(created_at: :desc).first
      history_item&.destroy
    end

    def send_sms?(transition)
      # user can chose to send sms or not, this generates a boolean from a transition parameter
      ActiveModel::Type::Boolean.new.cast(transition&.args&.first&.dig(:send_notification))
    end
  end
end
