FRENCH_DEPARTMENTS.each { |department| Department.find_or_create_by name: department.name, number: department.number }

organization = Organization.find_or_create_by name: 'SPIP 92'
AreasOrganizationsMapping.create organization: organization, area: Department.find_by(number: '92')

User.create!(
  organization: organization, email: 'admin@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :admin, first_name: 'Kevin', last_name: 'Mc Alistair'
)
place1 = Place.create!(
  organization: organization, name: "Tribunal judiciaire de Nanterre", adress: "179-191 av. Joliot Curie, 92020 NANTERRE", phone: '0606060606'
)
agenda1 = Agenda.create!(place: place1, name: "Agenda tribunal Ancenis")
appointment_type1 = AppointmentType.create!(name: "Sortie d'audience SAP")
PlaceAppointmentType.create!(place: place1, appointment_type: appointment_type1)

NotificationType.create!(appointment_type: appointment_type1, role: :summon, template: "Vous êtes convoqué, merci de venir.")
NotificationType.create!(appointment_type: appointment_type1, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days)
NotificationType.create!(appointment_type: appointment_type1, role: :cancelation, template: "Finalement non, c'est pas la peine.")
NotificationType.create!(appointment_type: appointment_type1, role: :no_show, template: "Vous n'êtes pas venu.")
NotificationType.create!(appointment_type: appointment_type1, role: :reschedule, template: "Changement du rdv de date X a date Y.")

SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :monday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :tuesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :tuesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)

place2 = Place.create!(organization: organization, name: "SPIP 92", adress: "94 Boulevard du Général Leclerc, 92000 Nanterre", phone: '0606060606')
agenda2 = Agenda.create!(place: place2, name: "Agenda tribunal Ancenis")

appointment_type2 = AppointmentType.create!(name: "Sortie d'audience SPIP")
PlaceAppointmentType.create!(place: place2, appointment_type: appointment_type2)

NotificationType.create!(appointment_type: appointment_type2, role: :summon, template: "Vous êtes convoqué, merci de venir.")
NotificationType.create!(appointment_type: appointment_type2, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days)
NotificationType.create!(appointment_type: appointment_type2, role: :cancelation, template: "Finalement non, c'est pas la peine.")
NotificationType.create!(appointment_type: appointment_type2, role: :no_show, template: "Vous n'êtes pas venu.")
NotificationType.create!(appointment_type: appointment_type2, role: :reschedule, template: "Changement du rdv de date X a date Y.")

SlotType.create(appointment_type: appointment_type2, agenda: agenda2, week_day: :monday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type2, agenda: agenda2, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type2, agenda: agenda2, week_day: :tuesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type2, agenda: agenda2, week_day: :tuesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type2, agenda: agenda2, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type2, agenda: agenda2, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)

all_dates = []
Date.today.upto(6.months.from_now.to_date) { |date| all_dates << date }

AppointmentType.all.each do |apt_type|
  agenda = apt_type.places.first.agendas.first

  apt_type.slot_types.each do |slot_type|
    dates = all_dates.select {|date| date.strftime("%A").downcase == slot_type.week_day }

    dates.each do |date|
      Slot.create!(
        date: date,
        agenda: agenda,
        slot_type: slot_type,
        appointment_type: apt_type,
        starting_time: slot_type.starting_time,
        duration: slot_type.duration,
        capacity: slot_type.capacity,
        available: true
      )
    end
  end
end

p 'Database seeded'
