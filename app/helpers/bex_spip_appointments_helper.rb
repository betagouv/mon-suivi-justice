module BexSpipAppointmentsHelper
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
