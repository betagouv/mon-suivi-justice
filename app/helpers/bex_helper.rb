module BexHelper
  def appointments_by_agenda(appointments)
    appointments.group_by { |a| a.slot.agenda.name }
  end

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
end
