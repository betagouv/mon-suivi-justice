module DataCollector
  def self.perform
    result = {}

    result[:convicts] = Convict.count
    result[:users] = User.count
    result[:notifications] = Notification.where(state: %w[sent received]).count

    result[:recorded] = Appointment.count
    result[:fulfiled] = Appointment.where(state: 'fulfiled').count
    result[:no_show] = Appointment.where(state: 'no_show').count
    result[:excused] = Appointment.where(state: 'excused').count
    result[:canceled] = Appointment.where(state: 'canceled').count

    result[:future_booked] = Appointment.where(state: 'booked').joins(:slot).where('slots.date >= ?', Date.today).count
    result[:passed_booked] = Appointment.where(state: 'booked').joins(:slot).where('slots.date < ?', Date.today).count
    result[:passed_no_canceled] = Appointment.joins(:slot).where('slots.date < ?', Date.today)
                                     .where.not(state: 'canceled').count
    result
  end
end
