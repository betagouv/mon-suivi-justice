module DataCollector
  class << self
    def perform
      result = {}
      result.merge!(basic_stats)
      result.merge!(appointments_stats)
      result.merge!(appointment_states_stats)
      result
    end

    private

    def basic_stats
      {
        convicts: Convict.count,
        convicts_with_phone: Convict.where.not(phone: nil).count,
        users: User.count,
        notifications: Notification.where(state: %w[sent received]).count
      }
    end

    def appointments_stats
      {
        recorded: Appointment.count,
        future_booked: future_booked.count,
        passed_booked: passed_booked.count,
        passed_booked_percentage: passed_booked_percentage,
        passed_no_canceled: passed_no_canceled.count,
        passed_no_canceled_with_phone: passed_no_canceled_with_phone.count
      }
    end

    def appointment_states_stats
      {
        fulfiled: fulfiled.count,
        fulfiled_percentage: fulfiled_percentage,
        no_show: no_show.count,
        no_show_percentage: no_show_percentage,
        excused: excused.count
      }
    end

    def future_booked
      Appointment.where(state: 'booked').joins(:slot)
                 .where('slots.date >= ?', Date.today)
    end

    def passed_booked
      Appointment.where(state: 'booked').joins(:slot)
                 .where('slots.date < ?', Date.today)
    end

    def passed_booked_percentage
      passed_booked.count * 100 / passed_no_canceled.count
    end

    def passed_no_canceled
      Appointment.where.not(state: 'canceled').joins(:slot)
                 .where('slots.date < ?', Date.today)
    end

    def passed_no_canceled_with_phone
      passed_no_canceled.joins(:convict).where.not(convicts: { phone: nil })
    end

    def fulfiled
      passed_no_canceled_with_phone.where(state: 'fulfiled')
    end

    def fulfiled_percentage
      fulfiled.count * 100 / passed_no_canceled_with_phone.count
    end

    def no_show
      passed_no_canceled_with_phone.where(state: 'no_show')
    end

    def no_show_percentage
      no_show.count * 100 / passed_no_canceled_with_phone.count
    end

    def excused
      passed_no_canceled_with_phone.where(state: 'excused')
    end
  end
end
