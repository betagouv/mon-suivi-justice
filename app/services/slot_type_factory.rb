module SlotTypeFactory
  class << self
    def perform(appointment_type:, agenda:, data:)
      open_days = format_open_days(data)
      starting_times = build_starting_times(
        first_slot: build_first_slot(data),
        last_slot: build_last_slot(data),
        interval: data[:interval]
      )

      open_days.each do |day|
        starting_times.each do |start|
          SlotType.create!(
            week_day: day,
            starting_time: start,
            duration: data[:duration],
            capacity: data[:capacity],
            appointment_type: appointment_type,
            agenda: agenda
          )
        end
      end
    end

    def build_starting_times(first_slot:, last_slot:, interval:)
      result = [first_slot]
      current_time = first_slot

      while current_time < last_slot
        current_time += interval.to_i * 60
        result << current_time
      end

      result
    end

    private

    def format_open_days(data)
      relevant_data = data.filter { |key, _| key.start_with?('day') }
      relevant_data.filter { |_, value| value == '1' }.keys
                   .collect { |day| day.to_s.delete_prefix('day_') }
    end

    def build_first_slot(data)
      Time.new(2021, 6, 21, data[:'first_slot(4i)'].to_i, data[:'first_slot(5i)'].to_i, 0, '+01:00')
    end

    def build_last_slot(data)
      Time.new(2021, 6, 21, data[:'last_slot(4i)'].to_i, data[:'last_slot(5i)'].to_i, 0, '+01:00')
    end
  end
end
