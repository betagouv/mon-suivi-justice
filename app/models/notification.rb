class Notification < ApplicationRecord
  has_paper_trail

  belongs_to :appointment
  validates :content, presence: true
  validates :external_id, presence: true, if: :sent?

  delegate :convict_phone, :convict, to: :appointment
  delegate :id, to: :appointment, prefix: true

  enum role: %i[summon reminder cancelation no_show reschedule]
  enum reminder_period: %i[one_day two_days]

  scope :in_organization, lambda { |organization|
    joins(appointment: { slot: { agenda: :place } })
      .where(appointment: { slots: { agendas: { places: { organization: } } } })
  }

  scope :all_sent, -> { where(state: %w[sent received failed]) }

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
      transition programmed: :canceled
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

    after_transition on: :program do |notification|
      SmsDeliveryJob.set(wait_until: notification.delivery_time)
                    .perform_later(notification.id)
    end
  end

  def delivery_time
    app_date = appointment.slot.date
    app_time = localized_starting_time

    app_datetime = app_date.to_datetime + app_time.seconds_since_midnight.seconds

    result = app_datetime.to_time - hour_delay.hours
    result.asctime.in_time_zone('Paris')
  end

  def localized_starting_time
    identifier = appointment.slot.place.organization.time_zone
    time_zone = TZInfo::Timezone.get(identifier)

    time_zone.to_local(appointment.slot.starting_time)
  end

  def hour_delay
    { 'one_day' => 24, 'two_days' => 48 }.fetch(reminder_period)
  end
end
