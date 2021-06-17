class Notification < ApplicationRecord
  belongs_to :appointment

  after_create do
    format_content
  end

  def send_now
    SendinblueAdapter.new.send_sms(self)
  end

  def format_content
    @slot = appointment.slot
    update(content: default_template)
  end

  def default_template
    "Vous avez rendez-vous au #{@slot.place.name} "\
    "le #{@slot.date.to_s(:base_date_format)} à "\
    "#{@slot.starting_time.to_s(:lettered)}."\
    " Merci d'arriver 15 minutes en avance au #{@slot.place.adress}."
  end
end
