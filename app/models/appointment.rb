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
  belongs_to :inviter_user, class_name: 'User', optional: true

  has_many :notifications, dependent: :destroy
  has_many :history_items, dependent: :destroy
  has_many :extra_fields, through: :appointment_extra_fields
  has_many :appointment_extra_fields, inverse_of: :appointment, autosave: true, dependent: :destroy

  accepts_nested_attributes_for :appointment_extra_fields, reject_if: :all_blank, limit: 4,
                                                           allow_destroy: true
  accepts_nested_attributes_for :slot

  delegate :date, :starting_time, :duration, :agenda, :appointment_type, :localized_time, :datetime, to: :slot
  delegate :name, :share_address_to_convict, to: :appointment_type, prefix: true
  delegate :place, to: :agenda
  delegate :name, to: :agenda, prefix: true
  delegate :organization, to: :place
  delegate :name, :adress, :phone, :contact_email, :main_contact_method,
           to: :place, prefix: true
  delegate :name, to: :organization, prefix: true
  delegate :phone, to: :convict, prefix: true

  attr_accessor :place_id, :agenda_id, :user_is_cpip, :send_sms

  enum origin_department: {
    bex: 0,
    gref_co: 1,
    pr: 2,
    greff_tpe: 3,
    greff_crpc: 4,
    greff_ca: 5
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
  validate :convict_is_not_discarded
  validate :convict_must_be_valid, on: :create

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
      event = :"#{transition.event}_appointment"
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

      should_send_summon = send_sms?(transition) && appointment.convict.can_receive_sms?
      roles = should_send_summon ? %i[summon reminder] : :reminder
      NotificationFactory.perform(appointment, roles)

      appointment.summon_notif&.program_now if should_send_summon
    end

    after_transition on: :cancel do |appointment, transition|
      appointment.decrease_slot_capacity
      appointment.cancel_reminder_notif

      if send_sms?(transition) && appointment.convict.can_receive_sms?
        NotificationFactory.perform(appointment, :cancelation)
        appointment.cancelation_notif&.program_now
      end
    end

    after_transition on: :miss do |appointment, transition|
      if send_sms?(transition) && appointment.convict.can_receive_sms?
        NotificationFactory.perform(appointment, :no_show)
        appointment.no_show_notif&.program_now
      end
    end

    after_transition on: :excuse do |appointment|
      appointment.decrease_slot_capacity
      appointment.cancel_reminder_notif
    end

    before_transition on: :rebook do |appointment, _|
      previous_event = appointment.state_paths(from: :booked, to: appointment.state.to_sym)
                                  .find { |a| a.length == 1 }.first.event.to_s

      history_item = appointment.history_items.where(event: :"#{previous_event}_appointment")
                                .order(created_at: :desc).first
      history_item&.destroy
    end

    def send_sms?(transition)
      # user can chose to send sms or not, this generates a boolean from a transition parameter
      ActiveModel::Type::Boolean.new.cast(transition&.args&.first&.dig(:send_notification)) # rubocop:disable Style/SafeNavigationChainLength
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[user_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[slot user]
  end

  def in_the_future
    if date.nil?
      errors.add(:base, I18n.t('activerecord.errors.models.appointment.attributes.date.blank'))
    elsif slot.datetime.before?(Time.zone.now)
      errors.add(:base, I18n.t('activerecord.errors.models.appointment.attributes.date.past'))
    elsif slot.datetime.after?(Time.zone.now + 1.year)
      errors.add(:base, I18n.t('activerecord.errors.models.appointment.attributes.date.future'))
    end
  end

  def in_the_past?
    slot.datetime.before?(Time.zone.now)
  end

  def in_the_future?
    slot.datetime.after?(Time.zone.now)
  end

  def must_choose_to_send_notification
    return if !convict&.can_receive_sms? || !send_sms.nil?

    errors.add(:base, I18n.t('activerecord.errors.models.appointment.attributes.send_sms.blank'))
  end

  def convict_is_not_discarded
    return unless convict&.discarded?

    errors.add(:convict, I18n.t('activerecord.errors.models.appointment.attributes.convict.discarded'))
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def convict_must_be_valid
    return if inviter_user_id.present? && inviter_user.admin?
    return if convict&.valid?

    errors.add(:convict, convict&.errors&.full_messages&.to_sentence) # rubocop:disable Style/SafeNavigationChainLength
  end
  # rubocop:enable Metrics/CyclomaticComplexity

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

  def decrease_slot_capacity
    return unless in_the_future?

    slot.decrement!(:used_capacity, 1) if slot.used_capacity.positive?
    slot.update(full: false) if slot.all_capacity_used? == false
  end

  def cancel_reminder_notif
    reminder_notif&.cancel! if reminder_notif&.pending?
  end

  def completed?
    fulfiled? || no_show? || excused?
  end

  def localized_starting_time
    identifier = slot.place.organization.time_zone
    time_zone = TZInfo::Timezone.get(identifier)

    time_zone.to_local(slot.starting_time)
  end
end
