module DataCollector
  class User < Base
    def perform
      result = defined?(@organization) ? { organization_name: @organization.name } : {}

      result.merge!(basic_stats)
            .merge!(appointments_stats)
            .merge!(appointment_states_stats)
    end

    private

    def basic_stats
      stats = {
        convicts: all_convicts.size,
        users: all_users.size
      }

      if @full_stats
        stats[:notifications] = all_notifications.all_sent.size
        stats[:convicts_with_phone] = all_convicts.with_phone.size
      end

      stats
    end

    # rubocop:disable Metrics/MethodLength
    def appointments_stats
      stats = {
        passed_no_canceled_with_phone: passed_no_canceled_with_phone.size,
        passed_uninformed_percentage: passed_uninformed_percentage,
        passed_informed: passed_informed.size
      }

      if @full_stats
        stats[:recorded] = all_appointments.size
        stats[:future_booked] = future_booked.size
        stats[:passed_uninformed] = passed_uninformed.size
      end

      stats
    end

    def appointment_states_stats
      stats = {
        fulfilled_percentage: fulfilled_percentage,
        no_show_percentage: no_show_percentage,
        excused_percentage: excused_percentage
      }

      if @full_stats
        stats[:no_show] = no_show.size
        stats[:fulfilled] = fulfilled.size
        stats[:excused] = excused.size
      end

      stats
    end
    # rubocop:enable Metrics/MethodLength

    def all_convicts
      @all_convicts ||= fetch_all_convicts
    end

    def fetch_all_convicts
      if defined?(@organization)
        ::Convict.under_hand_of(@organization)
      else
        ::Convict.all
      end
    end

    def all_users
      @all_users ||= fetch_all_users
    end

    def fetch_all_users
      if defined?(@organization)
        ::User.includes(:organization).where(organization: @organization)
      else
        ::User.all
      end
    end

    def all_notifications
      @all_notifications ||= fetch_all_notifications
    end

    def fetch_all_notifications
      if defined?(@organization)
        ::Notification.in_organization(@organization)
      else
        ::Notification.all
      end
    end

    def all_appointments
      @all_appointments ||= fetch_all_appointments
    end

    def fetch_all_appointments
      if defined?(@organization)
        ::Appointment.includes(:slot).in_organization(@organization)
      else
        ::Appointment.includes(:slot).all
      end
    end

    def future_booked
      all_appointments.where(state: 'booked').joins(:slot)
                      .where('slots.date >= ?', Date.today)
    end

    def passed_no_canceled
      all_appointments.where.not(state: 'canceled').joins(:slot)
                      .where('slots.date < ?', Date.today)
    end

    def passed_no_canceled_with_phone
      passed_no_canceled.joins(:convict).where.not(convicts: { phone: '' })
    end

    def passed_uninformed
      passed_no_canceled_with_phone.where(state: 'booked')
    end

    def passed_uninformed_percentage
      return 0 if passed_no_canceled_with_phone.empty?

      (passed_uninformed.size * 100.fdiv(passed_no_canceled_with_phone.size)).round
    end

    def passed_informed
      passed_no_canceled_with_phone.where.not(state: 'booked')
    end

    def fulfilled
      passed_informed.where(state: 'fulfiled')
    end

    def fulfilled_percentage
      return 0 if passed_informed.empty?

      (fulfilled.size * 100.fdiv(passed_informed.size)).round
    end

    def no_show
      passed_informed.where(state: 'no_show')
    end

    def no_show_percentage
      return 0 if passed_informed.empty?

      (no_show.size * 100.fdiv(passed_informed.size)).round
    end

    def excused
      passed_informed.where(state: 'excused')
    end

    def excused_percentage
      return 0 if passed_informed.empty?

      (excused.size * 100.fdiv(passed_informed.size)).round
    end
  end
end
