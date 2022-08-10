module HistoryItemFactory
  class << self
    def perform(event:, category:, appointment: nil, convict: nil, data: nil)
      HistoryItem.create!(
        convict: convict.present? ? convict : appointment.convict,
        appointment: appointment,
        category: category,
        event: event,
        content: build_content(event: event, category: category, appointment: appointment, convict: convict, data: data)
      )
    end

    private

    def build_content(event:, category:, appointment: nil, convict: nil, data: nil)
      case category
      when 'convict'
        content_for_convict(event: event, convict: convict, data: data)
      when 'appointment'
        content_for_appointment(event: event, appointment: appointment)
      when 'notification'
        content_for_notification(event: event, appointment: appointment)
      end
    end

    def content_for_convict(event:, convict:, data:)
      case event
      when 'archive_convict'
        I18n.t('history_item.archive_convict', name: convict.name)
      when 'unarchive_convict'
        I18n.t('history_item.unarchive_convict', name: convict.name)
      when 'update_phone_convict'
        I18n.t('history_item.update_phone_convict', name: convict.name, old_phone: data[:old_phone].phony_formatted,
                                                    new_phone: convict.display_phone, user_name: data[:user_name],
                                                    user_role: data[:user_role])
      when 'add_phone_convict'
        I18n.t('history_item.add_phone_convict', name: convict.name, new_phone: convict.display_phone,
                                                 user_name: data[:user_name], user_role: data[:user_role])
      when 'remove_phone_convict'
        I18n.t('history_item.remove_phone_convict', name: convict.name, old_phone: data[:old_phone].phony_formatted,
                                                    user_name: data[:user_name], user_role: data[:user_role])
      end
    end

    def content_for_appointment(event:, appointment:)
      if appointment.slot.appointment_type.name == 'RDV téléphonique'
        I18n.t('history_item.book_phone_appointment', name: appointment.convict.name,
                                                      date: appointment.slot.date,
                                                      time: appointment.slot.starting_time.to_s(:time))
      else
        I18n.t("history_item.#{event}", name: appointment.convict.name,
                                        place: appointment.slot.agenda.place.name,
                                        date: appointment.slot.date,
                                        time: appointment.slot.starting_time.to_s(:time))
      end
    end

    def content_for_notification(event:, appointment:)
      I18n.t("history_item.#{event}", name: appointment.convict.name,
                                      content: appointment.send(notification_role(event))&.content)
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
