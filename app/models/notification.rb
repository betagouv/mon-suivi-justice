class Notification < ApplicationRecord
  belongs_to :appointment
  validates :template, presence: true

  enum role: %i[summon reminder]

  after_create do
    format_content
  end

  # def send_later(time)
  #   SmsDeliveryJob.perform_later(opts)
  # end

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
      place_name: slot.place.name,
      place_adress: slot.place.adress
    }
  end
end
