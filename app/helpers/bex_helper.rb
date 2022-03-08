module BexHelper
  # Agenda JAP
  def ten_next_days_with_slots(appointment_type, organization)
    Slot.future
        .in_organization(organization)
        .where(appointment_type: appointment_type)
        .order(date: :asc)
        .group_by(&:date)
        .first(10)
        .map(&:first)
  end

  def first_day_with_slots(appointment_type, organization)
    ten_next_days_with_slots(appointment_type, organization).first
  end

  def available_slots_hours(date, agenda)
    agenda.slots.where(date: date)
          .pluck(:starting_time)
          .uniq.map { |time| time.to_s(:lettered) }
  end

  def appointments_by_agenda(appointments)
    appointments.group_by { |a| a.slot.agenda.name }
  end

  def select_appointment(appointments, hour)
    appointments.select do |a|
      a.slot.starting_time.to_s(:lettered) == hour
    end.first
  rescue NoMethodError
    # returns nil
  end

  # Agenda SPIP
  def six_next_months
    months = [Date.today]

    5.times { months << (months[-1] + 1.month) }

    months
  end

  def open_days_for_the_month(date)
    all_dates = (date.beginning_of_month..date.end_of_month).to_a
    week_dates = all_dates.reject { |d| d.sunday? || d.saturday? }
    holidays = Holidays.between(date.beginning_of_month, date.end_of_month, :fr)
                       .map { |h| h[:date] }

    week_dates - holidays
  end

  def appointments_for_a_day(appointments, day)
    appointments.to_a.select do |a|
      a.slot.date == day
    end
  end

  def appointment_of_the_hour(appointments, hour)
    appointments.to_a.select do |a|
      a.slot.starting_time.to_s(:lettered) == hour
    end.first
  end
end
