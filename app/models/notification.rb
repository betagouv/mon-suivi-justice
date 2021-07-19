class Notification < ApplicationRecord
  has_paper_trail

  belongs_to :appointment
  validates :template, presence: true

  enum role: %i[summon reminder]
  enum reminder_period: %i[one_day two_days]

  after_create do
    format_content
  end

  def send_later
    SmsDeliveryJob.set(wait_until: delivery_time).perform_later(self)
  end

  def send_now
    SmsDeliveryJob.perform_later(self)
  end

  def format_content
    update(content: template % sms_data)
  end

  def sms_data
    slot = appointment.slot
    {
      appointment_hour: slot.starting_time.to_s(:lettered),
      appointment_date: slot.date.to_s(:base_date_format),
      place_name: slot.agenda.place.name,
      place_adress: slot.agenda.place.adress,
      place_phone: slot.agenda.place.phone
    }
  end

  def delivery_time
    app_date = appointment.slot.date
    app_time = appointment.slot.starting_time

    app_datetime = app_date.to_datetime + app_time.seconds_since_midnight.seconds

    result = app_datetime.to_time - hour_delay.hours
    result.asctime.in_time_zone('Paris')
  end

  private

  HOUR_DELAYS = { "one_day" => 24, "two_days" => 48 }

  def hour_delay
    HOUR_DELAYS.fetch(reminder_period)
  end
end
