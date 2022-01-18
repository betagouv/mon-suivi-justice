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

  def all_convicts
    if defined?(@organization)
      Convict.under_hand_of(@organization)
    else
      Convict.all
    end
  end

  def all_users
    if defined?(@organization)
      User.where(organization: @organization)
    else
      User.all
    end
  end

  def all_notifications
    if defined?(@organization)
      Notification.in_organization(@organization)
    else
      Notification.all
    end
  end

  def all_appointments
    if defined?(@organization)
      Appointment.in_organization(@organization)
    else
      Appointment.all
    end
  end

  def basic_stats
    {
      convicts: all_convicts.size,
      convicts_with_phone: all_convicts.with_phone.size,
      users: all_users.size,
      notifications: all_notifications.all_sent.size
    }
  end

  def appointments_stats
    {
      recorded: all_appointments.size,
      future_booked: future_booked.size,
      passed_booked: passed_booked.size,
      passed_booked_percentage: passed_booked_percentage,
      passed_no_canceled_with_phone: passed_no_canceled_with_phone.size
    }
  end

  def appointment_states_stats
    {
      fulfiled: fulfiled.size,
      fulfiled_percentage: fulfiled_percentage,
      no_show: no_show.size,
      no_show_percentage: no_show_percentage,
      excused: excused.size
    }
  end

  def future_booked
    all_appointments.where(state: 'booked').joins(:slot)
                    .where('slots.date >= ?', Date.today)
  end

  def passed_booked
    all_appointments.where(state: 'booked').joins(:slot)
                    .where('slots.date < ?', Date.today)
  end

  def passed_booked_percentage
    return 0 if passed_no_canceled.size.zero?

    passed_booked.size * 100 / passed_no_canceled.size
  end

  def passed_no_canceled
    all_appointments.where.not(state: 'canceled').joins(:slot)
                    .where('slots.date < ?', Date.today)
  end

  def passed_no_canceled_with_phone
    passed_no_canceled.joins(:convict).where.not(convicts: { phone: nil })
  end

  def fulfiled
    passed_no_canceled_with_phone.where(state: 'fulfiled')
  end

  def fulfiled_percentage
    return 0 if passed_no_canceled_with_phone.size.zero?

    fulfiled.size * 100 / passed_no_canceled_with_phone.size
  end

  def no_show
    passed_no_canceled_with_phone.where(state: 'no_show')
  end

  def no_show_percentage
    return 0 if passed_no_canceled_with_phone.size.zero?

    no_show.size * 100 / passed_no_canceled_with_phone.size
  end

  def excused
    passed_no_canceled_with_phone.where(state: 'excused')
  end
end
