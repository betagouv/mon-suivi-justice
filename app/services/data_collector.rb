module DataCollector
  class << self
    def perform
      result = {}
      result.merge!(basic_stats)
      result.merge!(appointment_states_stats)
      result.merge!(advanced_stats)
      result
    end

    private

    def basic_stats
      {
        convicts: Convict.count,
        users: User.count,
        notifications: Notification.where(state: %w[sent received]).count
      }
    end

    def appointment_states_stats
      {
        recorded: Appointment.count,
        fulfiled: Appointment.where(state: 'fulfiled').count,
        no_show: Appointment.where(state: 'no_show').count,
        excused: Appointment.where(state: 'excused').count,
        canceled: Appointment.where(state: 'canceled').count
      }
    end

    def advanced_stats
      {
        future_booked: Appointment.where(state: 'booked').joins(:slot)
                                  .where('slots.date >= ?', Date.today).count,
        passed_booked: Appointment.where(state: 'booked').joins(:slot)
                                  .where('slots.date < ?', Date.today).count,
        passed_no_canceled: Appointment.where.not(state: 'canceled').joins(:slot)
                                       .where('slots.date < ?', Date.today).count
      }
    end
  end
end
