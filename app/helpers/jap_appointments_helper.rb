module JapAppointmentsHelper
  def ten_next_fridays
    fridays = [Date.today.next_occurring(:friday)]

    9.times { fridays << fridays[-1] + 1.week }

    fridays
  end

  def available_agendas
    ['Cabinet 1', 'Cabinet 2', 'Cabinet 3', 'Cabinet 4',
     'Cabinet 5', 'Cabinet 6', 'Cabinet 7']
  end

  def available_hours
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
end
