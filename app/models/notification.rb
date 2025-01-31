class Notification < ApplicationRecord
  has_paper_trail

  belongs_to :appointment
  validates :content, presence: true
  validates :external_id, presence: true, if: :sent?

  delegate :convict_phone, :convict, :appointment_type, :organization, :slot, to: :appointment
  delegate :id, to: :appointment, prefix: true
  delegate :can_receive_sms?, to: :convict, prefix: true

  enum role: %i[summon reminder cancelation no_show reschedule]
  enum reminder_period: %i[one_day two_days]

  scope :in_organization, lambda { |organization|
    joins(appointment: { slot: { agenda: :place } })
      .where(appointment: { slots: { agendas: { places: { organization: } } } })
  }

  scope :misrouted, -> { where(response_code: '16') }

  scope :to_reroute_link_mobility, -> { misrouted.with_state(:failed).where(delivery_time: 2.days.ago..Time.zone.now) }

  scope :all_sent, -> { where(state: %w[sent received failed]) }

  scope :appointment_after_today, lambda {
    joins(appointment: :slot)
      .where('slots.date > ?', Time.zone.today)
  }

  scope :appointment_more_than_1_month_ago, lambda {
    joins(appointment: :slot)
      .where('slots.date < ?', 1.month.ago)
  }

  scope :appointment_in_the_past, lambda {
    joins(appointment: :slot)
      .where('slots.date < ?', Time.zone.today)
  }

  scope :appointment_recently_past, lambda {
    joins(appointment: :slot)
      .where(slots: { date: 1.month.ago..Time.zone.yesterday })
  }

  scope :retryable, -> { where(failed_count: 0..4) }

  scope :ready_to_send, lambda {
    where(delivery_time: 1.hour.ago..1.hour.from_now, state: 'created')
  }

  state_machine initial: :created do
    state :created do
    end

    state :programmed do
    end

    state :canceled do
    end

    state :sent do
    end

    state :received do
    end

    state :unsent do
    end

    state :failed do
    end

    event :program do
      transition created: :programmed
    end

    event :program_now do
      transition created: :programmed
    end

    event :mark_as_sent do
      transition programmed: :sent
    end

    event :cancel do
      transition %i[created programmed] => :canceled
    end

    event :receive do
      transition sent: :received
    end

    event :mark_as_unsent do
      transition %i[created programmed] => :unsent
    end

    event :mark_as_failed do
      transition %i[created programmed] => :failed
    end

    after_transition do |notification, transition|
      event = :"#{transition.event}_#{notification.role}_notification"

      if HistoryItem.validate_event(event) == true
        HistoryItemFactory.perform(appointment: notification.appointment, event:, category: 'notification')
      end
    end

    after_transition on: :program_now do |notification|
      SmsDeliveryJob.perform_later(notification.id)
    end
  end

  def pending?
    programmed? || created?
  end

  def can_be_sent?
    convict_can_receive_sms? && (can_mark_as_sent? && role_conditions_valid? && failed_count < 5)
  end

  def role_conditions_valid?
    case role
    when 'summon', 'reminder', 'reschedule'
      appointment.in_the_future? && appointment.booked?
    when 'cancelation'
      appointment.in_the_future? && appointment.canceled?
    when 'no_show'
      appointment.in_the_past? && appointment.no_show?
    end
  end

  def handle_unsent!
    return if canceled?

    failed_count.zero? ? mark_as_unsent! : mark_as_failed!
  end

  def default_notif_type
    appointment_type.notification_types.find_by(organization: nil, role:)
  end

  def notification_type
    for_orga = appointment_type.notification_types.find_by(organization:, role:)
    return for_orga if for_orga.present?

    default_notif_type
  end

  # rubocop:disable Metrics/AbcSize
  def sms_data
    time_zone = TZInfo::Timezone.get(slot.place.organization.time_zone)
    {
      appointment_hour: time_zone.to_local(slot.starting_time).to_fs(:lettered),
      appointment_date: slot.civil_date,
      place_name: slot.place_name,
      place_adress: slot.place_adress,
      place_phone: slot.place_display_phone(spaces: false),
      place_contact: slot.place_contact_detail,
      place_preparation_link: "#{slot.place_preparation_link}?mtm_campaign=AgentsApp&mtm_source=sms"
    }
  end
  # rubocop:enable Metrics/AbcSize

  def generate_content(notif_type = nil)
    notif_type ||= notification_type
    template = notif_type.setup_template

    template % sms_data
  end
end
