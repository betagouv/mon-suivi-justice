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

    def build_content(category, appointment, event)
      case category
      when 'appointment'
        I18n.t("show_history_#{event}", name: appointment.convict.name,
                                        place: appointment.slot.agenda.place.name,
                                        date: appointment.slot.date,
                                        time: appointment.slot.starting_time.to_s(:time))
      when 'notification'
        I18n.t("show_history_#{event}", name: appointment.convict.name,
                                        content: appointment.send(notification_role(event))&.content)
      end
    end

    def notification_role(event)
      array = event.delete_suffix('_notification').split('_')
      array -= array.shift(2)

      "#{array.join('_')}_notif"
    end
  end
end
