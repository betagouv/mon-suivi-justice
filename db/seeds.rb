User.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password', role: :admin, first_name: 'Kevin', last_name: 'Mc Alistair')

place = Place.create!(name: "Tribunal d'Ancenis", adress: "133 Av. Robert Schuman, 44150 Ancenis", phone: '0606060606')
agenda = Agenda.create!(place: place, name: "Agenda tribunal Ancenis")

appointment_type = AppointmentType.create!(name: 'RDV de test SAP')
PlaceAppointmentType.create!(place: place, appointment_type: appointment_type)

NotificationType.create!(appointment_type: appointment_type, role: :summon, template: "Vous êtes convoqué, merci de venir.")
NotificationType.create!(appointment_type: appointment_type, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days)
NotificationType.create!(appointment_type: appointment_type, role: :cancelation, template: "Finalement non, c'est pas la peine.")

SlotType.create(appointment_type: appointment_type, week_day: :monday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type, week_day: :tuesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type, week_day: :tuesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)

all_dates = []
Date.today.upto(6.months.from_now.to_date) { |date| all_dates << date }

appointment_type.slot_types.each do |slot_type|
  dates = all_dates.select {|date| date.strftime("%A").downcase == slot_type.week_day }

  dates.each do |date|
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
p 'database seeded'
