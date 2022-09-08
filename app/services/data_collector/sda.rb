module DataCollector
  class Sda < Base
    def perform
      result = defined?(@organization) ? { organization_name: @organization.name } : {}

      result.merge!(sap_stats)
            .merge!(spip_stats)
    end

    private

    def sap_stats
      appointments = sda_sap_appointments

      { sortie_audience_sap: sda_base_data(appointments) }
    end

    def spip_stats
      appointments = sda_spip_appointments

      { sortie_audience_spip: sda_base_data(appointments) }
    end

    def sda_base_data(appointments)
      {
        convicts: appointments.pluck(:convict_id).uniq.count,
        average_delay: average_delay(appointments),
        recorded: appointments.size,
        future_booked: future_booked(appointments).size,
        passed_no_canceled_with_phone: passed_no_canceled_with_phone(appointments).size,
        passed_informed: passed_informed(appointments).size,
        passed_uninformed: passed_uninformed(appointments).size,
        passed_uninformed_percentage: passed_uninformed_percentage(appointments),
        fulfiled: fulfiled(appointments).size,
        fulfiled_percentage: fulfiled_percentage(appointments),
        no_show: no_show(appointments).size,
        no_show_percentage: no_show_percentage(appointments),
        excused: excused(appointments).size,
        excused_percentage: excused_percentage(appointments)
      }
    end

    def sda_spip_appointments
      apt_type = AppointmentType.find_by(name: "Sortie d'audience SPIP")

      appointments_by_appointment_type(apt_type)
    end

    def sda_sap_appointments
      apt_type = AppointmentType.find_by(name: "Sortie d'audience SAP")

      appointments_by_appointment_type(apt_type)
    end

    def appointments_by_appointment_type(apt_type)
      if defined?(@organization)
        ::Appointment.in_organization(@organization).joins(:slot).where(slot: { appointment_type: apt_type })
      else
        ::Appointment.joins(:slot).where(slot: { appointment_type: apt_type })
      end
    end

    def average_delay(appointments)
      delays = []
      appointments.each do |a|
        delays << (a.date - a.created_at.to_date).to_i
      end
      return 0 if delays.size == 0
      (delays.sum(0.0) / delays.size).round(1)
    end

    def future_booked(appointments)
      appointments.where(state: 'booked')
                  .where('slot.date >= ?', Date.today)
    end

    def passed_no_canceled(appointments)
      appointments.where.not(state: 'canceled')
                  .where('slot.date < ?', Date.today)
    end

    def passed_no_canceled_with_phone(appointments)
      passed_no_canceled(appointments).joins(:convict).where.not(convicts: { phone: '' })
    end

    def passed_uninformed(appointments)
      passed_no_canceled_with_phone(appointments).where(state: 'booked')
    end

    def passed_uninformed_percentage(appointments)
      return 0 if passed_no_canceled_with_phone(appointments).size.zero?

      (passed_uninformed(appointments).size * 100.fdiv(passed_no_canceled_with_phone(appointments).size)).round
    end

    def passed_informed(appointments)
      passed_no_canceled_with_phone(appointments).where.not(state: 'booked')
    end

    def fulfiled(appointments)
      passed_informed(appointments).where(state: 'fulfiled')
    end

    def fulfiled_percentage(appointments)
      return 0 if passed_informed(appointments).size.zero?

      (fulfiled(appointments).size * 100.fdiv(passed_informed(appointments).size)).round
    end

    def no_show(appointments)
      passed_informed(appointments).where(state: 'no_show')
    end

    def no_show_percentage(appointments)
      return 0 if passed_informed(appointments).size.zero?

      (no_show(appointments).size * 100.fdiv(passed_informed(appointments).size)).round
    end

    def excused(appointments)
      passed_informed(appointments).where(state: 'excused')
    end

    def excused_percentage(appointments)
      return 0 if passed_informed(appointments).size.zero?

      (excused(appointments).size * 100.fdiv(passed_informed(appointments).size)).round
    end
  end
end
