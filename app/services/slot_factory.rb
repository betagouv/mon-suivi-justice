module SlotFactory
  class << self
    def perform(start_date: Time.zone.now, end_date: 6.months.since)
      @start_date = start_date.to_date
      @end_date = end_date.to_date

      SlotType.kept.find_each do |slot_type|
        open_dates_on(slot_type.week_day).each do |date|
          create_slot date, slot_type
        end
      end
    end

    private

    def slot_exists(date, slot_type)
      Slot.exists? date: date, slot_type: slot_type, starting_time: slot_type.starting_time
    end

    def date_invalid?(date)
      date.blank? || date.saturday? || date.sunday? || Holidays.on(date, :fr).any?
    end

    def create_slot(date, slot_type)
      return unless date && slot_type
      return unless valid_date_for_slot(slot_type.place, date)
      return if slot_exists(date, slot_type) || date_invalid?(date)

      Slot.create(
        date: date, agenda: slot_type.agenda, slot_type: slot_type,
        appointment_type: slot_type.appointment_type, starting_time: slot_type.starting_time,
        duration: slot_type.duration, capacity: slot_type.capacity, available: true
      )
    end

    def open_dates_on(weekday)
      open_dates.select { |date| date.strftime('%A').downcase == weekday }
    end

    def open_dates
      @open_dates ||= (@start_date..@end_date).to_a - Holidays.between(@start_date, @end_date, :fr).map { |h| h[:date] }
    end
  end
end
