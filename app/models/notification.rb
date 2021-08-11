class Notification < ApplicationRecord
  has_paper_trail

  belongs_to :appointment
  validates :template, presence: true

  enum role: %i[summon reminder cancelation]
  enum reminder_period: %i[one_day two_days]

  state_machine initial: :created do
    state :created do
    end

    state :programmed do
    end

    state :canceled do
    end

    state :sent do
    end

    event :program do
      transition created: :programmed
    end

    event :send_now do
      transition created: :sent
    end

    event :send_then do
      transition programmed: :sent
    end

    event :cancel do
      transition [:created, :programmed] => :canceled
    end

    after_transition on: :send_now do |notification|
      SmsDeliveryJob.perform_later(notification)
    end

    after_transition on: :program do |notification|
      SmsDeliveryJob.set(wait_until: notification.delivery_time)
                    .perform_later(notification)
    end
  end

  def delivery_time
    app_date = appointment.slot.date
    app_time = appointment.slot.starting_time

    app_datetime = app_date.to_datetime + app_time.seconds_since_midnight.seconds

    result = app_datetime.to_time - hour_delay.hours
    result.asctime.in_time_zone('Paris')
  end

  def hour_delay
    { 'one_day' => 24, 'two_days' => 48 }.fetch(reminder_period)
  end
end
