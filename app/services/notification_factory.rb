module NotificationFactory
  class << self
    def perform(appointment, role)
      notif_types = select_notification_types(appointment, role)
      appointment.transaction do
        notif_types.each do |notif_type|
          template = setup_template(notif_type.template)
          Notification.create!(
            appointment:,
            role: notif_type.role,
            reminder_period: notif_type.reminder_period,
            content: template % sms_data(appointment.slot),
            delivery_time: notif_type.reminder? ? delivery_time(notif_type, appointment) : Time.zone.now
          )
        end
      end
    end

    def select_notification_types(appointment, role)
      notif_types = appointment.appointment_type.notification_types.where(organization: appointment.organization, role:)
      fill_with_default(appointment, notif_types)
    end

    def fill_with_default(appointment, notif_types)
      default_notif_types = appointment.appointment_type.notification_types.where(organization: nil)

      NotificationType.roles.each_key do |role|
        if notif_types.find_by(role:).nil?
          default = default_notif_types.where(role:)
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
        appointment_hour: time_zone.to_local(slot.starting_time).to_fs(:lettered),
        appointment_date: slot.civil_date,
        place_name: slot.place_name,
        place_adress: slot.place_adress,
        place_phone: slot.place_display_phone(spaces: false),
        place_contact: slot.place_contact_detail,
        place_preparation_link: "#{slot.place_preparation_link}?mtm_campaign=AgentsApp&mtm_source=sms"
      }
    end

    def delivery_time(notif_type, appointment)
      app_date = appointment.slot.date
      app_time = appointment.localized_starting_time

      app_datetime = app_date.to_datetime + app_time.seconds_since_midnight.seconds

      result = app_datetime.to_time - hour_delay(notif_type).hours
      result.asctime.in_time_zone('Paris')
    end

    def hour_delay(notif_type)
      { 'one_day' => 24, 'two_days' => 48 }.fetch(notif_type.reminder_period)
    end
  end
end
