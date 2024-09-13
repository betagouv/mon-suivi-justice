module NotificationFactory
  class << self
    def perform(appointment, roles)
      @appointment = appointment
      roles = [roles] unless roles.is_a?(Array)

      @appointment.transaction do
        roles.each do |role|
          notif = create_notif(role)
          notif.save!
        end
      end
    end

    def create_notif(role)
      notif = Notification.new(
        appointment: @appointment,
        role:
      )

      notif_type = notif.notification_type

      notif.reminder_period = notif_type.reminder_period
      notif.content = notif.generate_content(notif_type)
      notif.delivery_time = notif_type.reminder? ? delivery_time(notif_type) : Time.zone.now

      notif
    end

    def delivery_time(notif_type)
      app_date = @appointment.slot.date
      app_time = @appointment.localized_starting_time

      app_datetime = app_date.to_datetime + app_time.seconds_since_midnight.seconds

      result = app_datetime.to_time - hour_delay(notif_type).hours
      result.asctime.in_time_zone('Paris')
    end

    def hour_delay(notif_type)
      { 'one_day' => 24, 'two_days' => 48 }.fetch(notif_type.reminder_period)
    end
  end
end
