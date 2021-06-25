class Notification < ApplicationRecord
  belongs_to :appointment

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
    @slot = appointment.slot
    update(content: default_template)
  end

  def default_template
    "Vous êtes convoqué au #{@slot.place.name} "\
    "le #{@slot.date.to_s(:base_date_format)} à "\
    "#{@slot.starting_time.to_s(:lettered)}."\
    " Merci de venir avec une pièce d'identité au #{@slot.place.adress}."
  end
end
