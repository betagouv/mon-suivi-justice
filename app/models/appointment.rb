class Appointment < ApplicationRecord
  include TransfertValidator

  has_paper_trail

  after_destroy do |appointment|
    appointment.slot.decrement!(:used_capacity, 1) if appointment.slot.used_capacity.positive?
    appointment.slot.update(full: false) if appointment.slot.all_capacity_used? == false
  end

  belongs_to :convict
  belongs_to :slot
  belongs_to :user, optional: true
  belongs_to :creating_organization, class_name: 'Organization', optional: true

  has_many :notifications, dependent: :destroy
  has_many :history_items, dependent: :destroy
  has_many :extra_fields, through: :appointment_extra_fields
  has_many :appointment_extra_fields, inverse_of: :appointment, autosave: true, dependent: :destroy

  accepts_nested_attributes_for :appointment_extra_fields, reject_if: :all_blank, limit: 3,
                                                           allow_destroy: true
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

  attr_accessor :place_id, :agenda_id, :department_id, :user_is_cpip, :send_sms

  enum origin_department: {
    bex: 0,
    gref_co: 1,
    pr: 2,
    greff_tpe: 3,
    greff_crpc: 4,
    greff_ca: 5
  }

  scope :for_a_date, ->(date = Time.zone.today) { joins(:slot).where('slots.date' => date) }

  scope :for_a_place, lambda { |place|
    joins(slot: { agenda: :place }).where(slots: { agendas: { places: place } })
  }

  scope :for_a_month, lambda { |date = Time.zone.today|
    joins(:slot).where('extract(month from slots.date) = ?', date.month)
  }

  scope :in_organization, lambda { |organization|
    joins(slot: [{ agenda: :place }, :appointment_type]).where(slots: { agendas: { places: { organization: } } })
  }

  scope :in_jurisdiction, lambda { |user_organization|
    joins(:slot, convict: :organizations)
      .where(convict: { organizations: [user_organization, *user_organization.linked_organizations] })
  }

  scope :created_by_organization, lambda { |user_organization|
    joins(:slot, convict: :organizations)
      .where(creating_organization: user_organization)
  }

  scope :active, -> { where.not(state: 'canceled') }

  validate :in_the_future, on: :create
  validate :must_choose_to_send_notification, on: :create

  def self.ransackable_attributes(_auth_object = nil)
    %w[user_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[slot user]
  end

  def in_the_future
    if slot.date.nil?
      errors.add(:base, I18n.t('activerecord.errors.models.appointment.attributes.date.blank'))
    elsif slot.date < Time.zone.today
      errors.add(:base, I18n.t('activerecord.errors.models.appointment.attributes.date.past'))
    end
  end

  def in_the_past?
    return true if date < Time.zone.today

    date == Time.zone.today && starting_time.strftime('%H:%M') <= Time.current.strftime('%H:%M')
  end

  def must_choose_to_send_notification
    return if convict&.phone.blank? || !send_sms.nil?

    errors.add(:base, I18n.t('activerecord.errors.models.appointment.attributes.send_sms.blank'))
  end

  def datetime
    DateTime.new(date.year, date.month, date.day,
                 localized_time.hour, localized_time.min, localized_time.sec, localized_time.zone)
  end

  def localized_time
    time_zone = TZInfo::Timezone.get(slot.place.organization.time_zone)
    time_zone.to_local(starting_time)
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

  def add_transfert_error(transfert, attribute, place_name)
    errors.add(:base,
               I18n.t("activerecord.errors.models.appointment.attributes.date.#{attribute}", date: transfert.date,
                                                                                             place_name:))
  end

  def in_organization?(orga)
    organization == orga
  end

  def in_jurisdiction?(orga)
    convict.organizations.include?(orga) || convict.organizations.to_a.intersection(orga.linked_organizations).any?
  end

  def created_by_organization?(orga)
    creating_organization == orga
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
          appointment:,
          event:,
          category: 'appointment'
        )
      end
    end

    after_transition on: :book do |appointment, transition|
      appointment.slot.increment!(:used_capacity, 1)
      appointment.slot.update(full: true) if appointment.slot.all_capacity_used?

      appointment.transaction do
        NotificationFactory.perform(appointment)
        appointment.summon_notif.send_now if send_sms?(transition) && appointment.convict.can_receive_sms?
        appointment.reminder_notif&.program
      end
    end

    after_transition on: :cancel do |appointment, transition|
      appointment.slot.decrement!(:used_capacity, 1) if appointment.slot.used_capacity.positive?
      appointment.slot.update(full: false) if appointment.slot.all_capacity_used? == false

      appointment.reminder_notif.cancel! if appointment.reminder_notif&.programmed?

      if send_sms?(transition) && appointment.convict.phone.present?
        appointment.cancelation_notif.send_now
      end
    end

    after_transition on: :miss do |appointment, transition|
      appointment.no_show_notif&.send_now if send_sms?(transition)
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
