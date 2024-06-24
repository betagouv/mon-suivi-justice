module HistoryItemFactory
  class << self
    def perform(event:, category:, appointment: nil, convict: nil, data: nil)
      HistoryItem.create!(
        convict: convict.present? ? convict : appointment.convict,
        appointment:,
        category:,
        event:,
        content: build_content(event:, category:, appointment:, convict:, data:)
      )
    end

    private

    def build_content(event:, category:, appointment: nil, convict: nil, data: nil)
      case category
      when 'convict'
        content_for_convict(event:, convict:, data:)
      when 'appointment'
        content_for_appointment(event:, appointment:)
      when 'notification'
        content_for_notification(event:, appointment:)
      end
    end

    # rubocop:disable Metrics/CyclomaticComplexity
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
      when 'refuse_divestment'
        relevant_org_divestment = data[:divestment].organization_divestments.with_state(:refused).first
        comment = relevant_org_divestment.comment.present? ? relevant_org_divestment.comment : 'décision sans commentaire'
        I18n.t('history_item.refuse_divestment', comment:, organization_name: relevant_org_divestment.organization_name,
                                                 target_name: data[:divestment].organization_name)
      when 'accept_divestment'
        I18n.t('history_item.accept_divestment', target_name: data[:divestment].organization_name)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def content_for_appointment(event:, appointment:)
      if appointment.slot.appointment_type.name == 'RDV téléphonique'
        I18n.t('history_item.book_phone_appointment', name: appointment.convict.name,
                                                      date: appointment.slot.date,
                                                      time: appointment.localized_time.to_fs(:time))
      else
        I18n.t("history_item.#{event}", name: appointment.convict.name,
                                        place: appointment.slot.agenda.place.name,
                                        date: appointment.slot.date.to_fs,
                                        time: appointment.localized_time.to_fs(:time))
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
