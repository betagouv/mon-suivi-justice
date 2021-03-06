FRENCH_DEPARTMENTS.each do |department|
  Department.find_or_create_by name: department.name, number: department.number
  puts "Department #{department.name} created"
end

organization1 = Organization.create!(name: 'SPIP 92', organization_type: 'spip')
puts "Organization #{organization1.name} created"

organization2 = Organization.create!(name: 'TJ Nanterre', organization_type: 'tj')
puts "Organization #{organization2.name} created"

AreasOrganizationsMapping.create organization: organization1, area: Department.find_by(number: '92')
AreasOrganizationsMapping.create organization: organization2, area: Department.find_by(number: '92')

convict = Convict.create!(first_name: "Michel", last_name: "Blabla", phone: "0677777777", appi_uuid: "12345")
puts "Convict #{convict.phone} created"
AreasConvictsMapping.create convict: convict, area: Department.find_by(number: '92')

user = User.create!(
        organization: organization1, email: 'admin@example.com', password: '1mot2passeSecurise!',
        password_confirmation: '1mot2passeSecurise!', role: :admin, first_name: 'Kevin', last_name: 'McCallister'
      )
puts "User #{user.email} created"

place1 = Place.create!(
  organization: organization2, name: "Tribunal judiciaire de Nanterre", adress: "179-191 av. Joliot Curie, 92020 NANTERRE", phone: '0606060606'
)
puts "Place #{place1.name} created"

agenda1 = Agenda.create!(place: place1, name: "Agenda 1 tribunal Nanterre")
puts "Agenda #{agenda1.name} created"
agenda2 = Agenda.create!(place: place1, name: "Agenda 2 tribunal Nanterre")
puts "Agenda #{agenda2.name} created"
appointment_type1 = AppointmentType.create!(name: "Sortie d'audience SAP")
puts "AppointmentType #{appointment_type1.name} created"
appointment_type2 = AppointmentType.create!(name: 'RDV de suivi JAP')
puts "AppointmentType #{appointment_type2.name} created"
PlaceAppointmentType.create!(place: place1, appointment_type: appointment_type1)
PlaceAppointmentType.create!(place: place1, appointment_type: appointment_type2)

NotificationType.create!(appointment_type: appointment_type1, role: :summon, template: "Vous ??tes convoqu??, merci de venir.")
NotificationType.create!(appointment_type: appointment_type1, role: :reminder, template: "RAPPEL Vous ??tes convoqu??, vraiment il faut venir.", reminder_period: :two_days)
NotificationType.create!(appointment_type: appointment_type1, role: :cancelation, template: "Finalement non, c'est pas la peine.")
NotificationType.create!(appointment_type: appointment_type1, role: :no_show, template: "Vous n'??tes pas venu :(")
NotificationType.create!(appointment_type: appointment_type1, role: :reschedule, template: "Changement du rdv de date X a date Y.")
NotificationType.create!(appointment_type: appointment_type2, role: :summon, template: "Vous ??tes convoqu??, merci de venir.")
NotificationType.create!(appointment_type: appointment_type2, role: :reminder, template: "RAPPEL Vous ??tes convoqu??, vraiment il faut venir.", reminder_period: :two_days)
NotificationType.create!(appointment_type: appointment_type2, role: :cancelation, template: "Finalement non, c'est pas la peine.")
NotificationType.create!(appointment_type: appointment_type2, role: :no_show, template: "Vous n'??tes pas venu :(")
NotificationType.create!(appointment_type: appointment_type2, role: :reschedule, template: "Changement du rdv de date X a date Y.")

SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :monday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :tuesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :tuesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)

place2 = Place.create!(organization: organization1, name: "SPIP 92", adress: "94 Boulevard du G??n??ral Leclerc, 92000 Nanterre", phone: '0606060606')
puts "Place #{place2.name} created"
agenda3 = Agenda.create!(place: place2, name: "Agenda SPIP 92")
puts "Agenda #{agenda3.name} created"

appointment_type2 = AppointmentType.create!(name: "RDV de suivi SPIP")
puts "AppointmentType #{appointment_type2.name} created"
PlaceAppointmentType.create!(place: place2, appointment_type: appointment_type2)

NotificationType.create!(appointment_type: appointment_type2, role: :summon, template: "Vous ??tes convoqu??, merci de venir.")
NotificationType.create!(appointment_type: appointment_type2, role: :reminder, template: "RAPPEL Vous ??tes convoqu??, vraiment il faut venir.", reminder_period: :two_days)
NotificationType.create!(appointment_type: appointment_type2, role: :cancelation, template: "Finalement non, c'est pas la peine.")
NotificationType.create!(appointment_type: appointment_type2, role: :no_show, template: "Vous n'??tes pas venu :(")
NotificationType.create!(appointment_type: appointment_type2, role: :reschedule, template: "Changement du rdv de date X a date Y.")

SlotType.create(appointment_type: appointment_type2, agenda: agenda2, week_day: :monday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type2, agenda: agenda2, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type2, agenda: agenda2, week_day: :tuesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type2, agenda: agenda2, week_day: :tuesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type2, agenda: agenda2, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type2, agenda: agenda2, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)

SlotFactory.perform

p 'Database seeded'
