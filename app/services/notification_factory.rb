module NotificationFactory
  class << self
    def perform(appointment, roles)
      @appointment = appointment
      roles = cleanup Array(roles)

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
      return Time.zone.now if before_hours_delay?(notif_type)

      app_date = @appointment.slot.date
      app_time = @appointment.localized_starting_time

      app_datetime = app_date.to_datetime + app_time.seconds_since_midnight.seconds

      result = app_datetime.to_time - hour_delay(notif_type).hours
      result.asctime.in_time_zone('Paris')
    end

    def hour_delay(notif_type)
      { 'one_day' => 24, 'two_days' => 48 }.fetch(notif_type.reminder_period)
    end

    def before_hours_delay?(notif_type)
      return false unless notif_type.reminder?

      delay = hour_delay(notif_type)
      datetime = @appointment.slot.datetime

      datetime < delay.hours.from_now
    end

    def cleanup(roles)
      return roles unless contains_all(roles, %w[reminder summon])

      reminder_notif_type = @appointment.reminder_notification_type
      return roles - ['reminder'] if before_hours_delay? reminder_notif_type

      roles
    end

    def contains_all(array, values)
      (values - array).empty?
    end
  end
end
