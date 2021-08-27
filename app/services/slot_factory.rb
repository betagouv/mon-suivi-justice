class SlotFactory
  def initialize(start_date: Time.zone.now, end_date: 6.months.since)
    @start_date = start_date.to_date
    @end_date = end_date.to_date

    AppointmentType.find_each { |appointment_type| create_slot_for_all_places(appointment_type) }
  end

  private

  def create_slot_for_all_places(appointment_type)
    concerned_places(appointment_type.place_type).each do |place|
      create_slots_on_all_agendas(appointment_type, place)
    end
  end

  def create_slots_on_all_agendas(appointment_type, place)
    place.agendas.each do |agenda|
      create_slots_for_all_slot_types(appointment_type, place, agenda)
    end
  end

  def create_slots_for_all_slot_types(appointment_type, place, agenda)
    appointment_type.slot_types.each do |slot_type|
      create_slots_on_all_dates(appointment_type, place, agenda, slot_type)
    end
  end

  def create_slots_on_all_dates(appointment_type, place, agenda, slot_type)
    open_dates_on(slot_type.week_day).each do |date|
      create_slot_with appointment_type, place, agenda, slot_type, date
    end
  end

  def create_slot_with(appointment_type, _place, agenda, slot_type, date)
    return if slot_exists(date, agenda, appointment_type, slot_type)

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

  def slot_exists(date, agenda, appointment_type, slot_type)
    Slot.exists? date: date, agenda: agenda, appointment_type: appointment_type, starting_time: slot_type.starting_time
  end

  def concerned_places(place_type)
    Place.all.where place_type: place_type
  end

  def open_dates_on(weekday)
    open_dates.select { |date| date.strftime('%A').downcase == weekday }
  end

  def open_dates
    @open_dates ||= (@start_date..@end_date).to_a - Holidays.between(@start_date, @end_date, :fr).map { |h| h[:date] }
  end
end
