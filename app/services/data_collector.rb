class DataCollector
  def initialize(organization_id: nil)
    @organization = Organization.find(organization_id) if organization_id.present?
  end

  def perform
    result = defined?(@organization) ? { organization_name: @organization.name } : {}

    result.merge!(basic_stats)
          .merge!(appointments_stats)
          .merge!(appointment_states_stats)
  end

  private

  def total_convict
    if defined?(@organization)
      Convict.under_hand_of(@organization)
    else
      Convict.all
    end
  end

  def total_user
    if defined?(@organization)
      User.where(organization: @organization)
    else
      User.all
    end
  end

  def total_notification
    if defined?(@organization)
      Notification.in_organization(@organization)
    else
      Notification.all
    end
  end

  def total_appointments
    if defined?(@organization)
      Appointment.in_organization(@organization)
    else
      Appointment.all
    end
  end

  def basic_stats
    {
      convicts: total_convict.count,
      convicts_with_phone: total_convict.where.not(phone: nil).count,
      users: total_user.count,
      notifications: total_notification.where(state: %w[sent received]).count
    }
  end

  def appointments_stats
    {
      recorded: total_appointments.count,
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
    total_appointments.where(state: 'booked').joins(:slot)
                      .where('slots.date >= ?', Date.today)
  end

  def passed_booked
    total_appointments.where(state: 'booked').joins(:slot)
                      .where('slots.date < ?', Date.today)
  end

  def passed_booked_percentage
    return 0 if passed_no_canceled.count.zero?

    passed_booked.count * 100 / passed_no_canceled.count
  end

  def passed_no_canceled
    total_appointments.where.not(state: 'canceled').joins(:slot)
                      .where('slots.date < ?', Date.today)
  end

  def passed_no_canceled_with_phone
    passed_no_canceled.joins(:convict).where.not(convicts: { phone: nil })
  end

  def fulfiled
    passed_no_canceled_with_phone.where(state: 'fulfiled')
  end

  def fulfiled_percentage
    return 0 if passed_no_canceled_with_phone.count.zero?

    fulfiled.count * 100 / passed_no_canceled_with_phone.count
  end

  def no_show
    passed_no_canceled_with_phone.where(state: 'no_show')
  end

  def no_show_percentage
    return 0 if passed_no_canceled_with_phone.count.zero?

    no_show.count * 100 / passed_no_canceled_with_phone.count
  end

  def excused
    passed_no_canceled_with_phone.where(state: 'excused')
  end
end
