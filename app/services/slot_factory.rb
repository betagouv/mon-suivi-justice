module SlotFactory
  def initialize
    # rails r bin/slot_generator.rb
    #   generates slots for all places
    # rails r bin/slot_generator.rb 3 4
    #   generates slots for places with id of 3 and 4

    # create 6 month of slots for all places taking infos from all appointment_types
    # + take national holidays into account

    start_date = Date.today
    end_date = 6.months.from_now.to_date
    all_dates = []

    holidays = Holidays.between(start_date, end_date, :fr).map { |h| h[:date] }
    start_date.upto(end_date) { |date| all_dates << date }
    open_dates = all_dates - holidays

    places = Place.all

    AppointmentType.all.each do |appointment_type|
      concerned_places = places.where(place_type: appointment_type.place_type)

      concerned_places.each do |place|
        place.agendas.each do |agenda|
          appointment_type.slot_types.each do |slot_type|
            dates = open_dates.select { |date| date.strftime("%A").downcase == slot_type.week_day }

            dates.each do |date|
              existing = Slot.where(
                date: date,
                agenda: agenda,
                appointment_type: appointment_type,
                starting_time: slot_type.starting_time
              )

              next if existing.present?

              Slot.create!(
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
