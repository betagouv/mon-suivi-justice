module HistoryItemFactory
  class << self
    def perform(appointment:, event:, category:)
      content = build_content(category, appointment, event)
      HistoryItem.create!(
        convict: appointment.convict,
        appointment: appointment,
        category: category,
        event: event,
        content: content
      )
    end

    private

    def build_content(category, appointment, event)
      case category
      when 'appointment'
        if appointment.slot.appointment_type == 'RDV téléphonique'
          I18n.t('show_history_book_phone_appointment', name: appointment.convict.name,
                                                        date: appointment.slot.date,
                                                        time: appointment.slot.starting_time.to_s(:time))
        else
          I18n.t("show_history_#{event}", name: appointment.convict.name,
                                          place: appointment.slot.agenda.place.name,
                                          date: appointment.slot.date,
                                          time: appointment.slot.starting_time.to_s(:time))
        end
      when 'notification'
        I18n.t("show_history_#{event}", name: appointment.convict.name,
                                        content: appointment.send(notification_role(event))&.content)
      end
    end

    def notification_role(event)
      array = event.to_s.delete_suffix('_notification').split('_')

      array -= if array.first == 'cancel'
                 array.shift(1)
               else
                 array.shift(2)
               end

      "#{array.join('_')}_notif"
    end
  end
end
