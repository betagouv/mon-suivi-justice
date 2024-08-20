module Notifications
  class ToBeMarkedAsFailedQuery
    def call
      high_failure_notifications
        .or(stuck_no_show_notifications)
        .or(other_stuck_notifications)
    end

    private

    def high_failure_notifications
      Notification.joins(appointment: :slot)
                  .where(state: %w[created programmed], failed_count: 5..)
    end

    def stuck_no_show_notifications
      Notification.appointment_more_than_1_month_ago
                  .where(state: 'programmed', role: 'no_show')
    end

    def other_stuck_notifications
      Notification.appointment_in_the_past
                  .where(state: 'programmed', role: %w[reminder summon cancelation reschedule])
    end
  end
end
