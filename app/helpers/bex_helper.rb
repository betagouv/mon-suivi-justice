module BexHelper
  # Agenda JAP
  def ten_next_fridays
    fridays = [Date.today.next_occurring(:friday)]

    9.times { fridays << fridays[-1] + 1.week }

    fridays
  end

  def available_agendas
    ['Cabinet 1', 'Cabinet 2', 'Cabinet 3', 'Cabinet 4',
     'Cabinet 5', 'Cabinet 6', 'Cabinet 7']
  end

  def bex_jap_available_hours
    %w[9h30 10h00 10h30 11h00 11h30]
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

    5.times { months << months[-1] + 1.month }

    months
  end

  def bex_spip_available_hours
    %w[09h00 14h00 14h45 15h30 16h15]
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
