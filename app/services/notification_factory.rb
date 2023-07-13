module NotificationFactory
  class << self
    def perform(appointment)
      notif_types = select_notification_types(appointment)

      notif_types.each do |notif_type|
        template = setup_template(notif_type.template)

        Notification.create!(
          appointment: appointment,
          role: notif_type.role,
          reminder_period: notif_type.reminder_period,
          content: template % sms_data(appointment.slot)
        )
      end
    end

    def select_notification_types(appointment)
      notif_types = appointment.appointment_type.notification_types.where(organization: appointment.organization)
      fill_with_default(appointment, notif_types)
    end

    def fill_with_default(appointment, notif_types)
      default_notif_types = appointment.appointment_type.notification_types.where(organization: nil)

      NotificationType.roles.each_key do |role|
        if notif_types.find_by(role: role).nil?
          default = default_notif_types.where(role: role)
          notif_types = notif_types.or(default) unless default.empty?
        end
      end

      notif_types
    end

    def setup_template(notif_type_template)
      notif_type_template.gsub('{', '%{')
                         .gsub('rdv.heure', 'appointment_hour')
                         .gsub('rdv.date', 'appointment_date')
                         .gsub('lieu.nom', 'place_name')
                         .gsub('lieu.adresse', 'place_adress')
                         .gsub('lieu.téléphone', 'place_phone')
                         .gsub('lieu.contact', 'place_contact')
                         .gsub('lieu.lien_info', 'place_preparation_link')
    end

    def sms_data(slot)
      time_zone = TZInfo::Timezone.get(slot.place.organization.time_zone)
      {
        appointment_hour: time_zone.to_local(slot.starting_time).to_s(:lettered),
        appointment_date: slot.date.to_s(:base_date_format),
        place_name: slot.place_name,
        place_adress: slot.place_adress,
        place_phone: slot.place_display_phone(spaces: false),
        place_contact: slot.place_contact_detail,
        place_preparation_link: "#{slot.place_preparation_link}?mtm_campaign=AgentsApp&mtm_source=sms"
      }
    end
  end
end
