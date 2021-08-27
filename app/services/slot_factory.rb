module SlotFactory
  def initialize
    start_date = Time.zone.now
    end_date = 6.months.since.to_date
    holidays = Holidays.between(start_date, end_date, :fr).map { |h| h[:date] }
    open_dates = (start_date..end_date).to_a - holidays

    AppointmentType.find_each do |appointment_type|
      concerned_places = Place.all.where place_type: appointment_type.place_type

      concerned_places.each do |place|
        place.agendas.each do |agenda|
          appointment_type.slot_types.each do |slot_type|
            dates = open_dates.select { |date| date.strftime("%A").downcase == slot_type.week_day }

            dates.each do |date|
              next if Slot.exists? date: date, agenda: agenda,  appointment_type: appointment_type, starting_time: slot_type.starting_time

              Slot.create(
                date: date,
                agenda: agenda,
                appointment_type: appointment_type,
                starting_time: slot_type.starting_time,
                duration: slot_type.duration,
                capacity: slot_type.capacity,
                available: true
              )
            end
          end
        end
      end
    end
  end
end
