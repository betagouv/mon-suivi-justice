FRENCH_DEPARTMENTS.each do |department|
  Department.find_or_create_by name: department.name, number: department.number
end

FRENCH_JURISDICTIONS.each do |name|
  Jurisdiction.find_or_create_by(name: name)
end

organization1 = Organization.create!(name: 'SPIP 92', organization_type: 'spip')
puts "Organization #{organization1.name} created"

organization2 = Organization.create!(name: 'TJ Nanterre', organization_type: 'tj')
puts "Organization #{organization2.name} created"

orgSpip75 = Organization.create!(name: 'SPIP 75', organization_type: 'spip')
puts "Organization #{orgSpip75.name} created"

# Un service peut être rattaché à des départements et/ou des juridictions
# Cela impacte le rattachement des ppsmj à tel  département et/ou juridiction à leur création
AreasOrganizationsMapping.create organization: organization1, area: Department.find_by(number: '92')
AreasOrganizationsMapping.create organization: organization1, area: Jurisdiction.find_by(name: 'TJ NANTERRE')

AreasOrganizationsMapping.create organization: organization2, area: Department.find_by(number: '92')

AreasOrganizationsMapping.create organization: orgSpip75, area: Department.find_by(number: '75')

convict = Convict.create!(first_name: "Michel", last_name: "Blabla", phone: "0677777777", appi_uuid: "12345")
puts "Convict #{convict.phone} created"

convict2 = Convict.create!(first_name: "Dark", last_name: "Vador", phone: "0600000000", appi_uuid: "12346")
puts "Convict #{convict2.phone} created"

AreasConvictsMapping.create convict: convict, area: Department.find_by(number: '92')
AreasConvictsMapping.create convict: convict2, area: Department.find_by(number: '92')


admin = User.create!(
        organization: organization1, email: 'admin@example.com', password: '1mot2passeSecurise!',
        password_confirmation: '1mot2passeSecurise!', role: :admin, first_name: 'Kevin', last_name: 'McCallister'
      )
puts "User #{admin.email} created"

cpip = User.create!(
  organization: organization1, email: 'cpip@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :cpip, first_name: 'Bob', last_name: 'Dupneu'
)
puts "CPIP #{cpip.first_name} created"

cpip2 = User.create!(
  organization: orgSpip75, email: 'cpip75@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :cpip, first_name: 'Luke', last_name: 'Skywalker'
)
puts "CPIP #{cpip2.first_name} created"

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

NotificationType.create!(appointment_type: appointment_type1, role: :summon, template: "Vous êtes convoqué, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: appointment_type1, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: appointment_type1, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: appointment_type1, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: appointment_type1, role: :reschedule, template: "Changement du rdv de date X a date Y.", is_default: true)
NotificationType.create!(appointment_type: appointment_type2, role: :summon, template: "Vous êtes convoqué, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: appointment_type2, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: appointment_type2, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: appointment_type2, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: appointment_type2, role: :reschedule, template: "Changement du rdv de date X a date Y.", is_default: true)

SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type1, agenda: agenda1, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)

place2 = Place.create!(organization: organization1, name: "SPIP 92", adress: "94 Boulevard du Général Leclerc, 92000 Nanterre", phone: '0606060606')
puts "Place #{place2.name} created"
agenda3 = Agenda.create!(place: place2, name: "Agenda SPIP 92")
puts "Agenda #{agenda3.name} created"

appointment_type3 = AppointmentType.create!(name: "RDV de suivi SPIP")
puts "AppointmentType #{appointment_type3.name} created"
PlaceAppointmentType.create!(place: place2, appointment_type: appointment_type3)

NotificationType.create!(appointment_type: appointment_type3, role: :summon, template: "Vous êtes convoqué, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: appointment_type3, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: appointment_type3, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: appointment_type3, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: appointment_type3, role: :reschedule, template: "Changement du rdv de date X a date Y.", is_default: true)

appointment_type4 = AppointmentType.create!(name: "Sortie d'audience SPIP")
puts "AppointmentType #{appointment_type4.name} created"
PlaceAppointmentType.create!(place: place2, appointment_type: appointment_type4)
NotificationType.create!(appointment_type: appointment_type4, role: :summon, template: "Vous êtes convoqué à votre sortie d'audience SPIP, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: appointment_type4, role: :reminder, template: "RAPPEL Vous êtes convoqué à votre sortie d'audience SPIP, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: appointment_type4, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: appointment_type4, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: appointment_type4, role: :reschedule, template: "Changement du rdv de date X a date Y.", is_default: true)

SlotType.create(appointment_type: appointment_type4, agenda: agenda3, week_day: :monday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type4, agenda: agenda3, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)

orgSpip75place1 = Place.create!(
  organization: orgSpip75, name: "SPIP 75", adress: "12-14 rue Charles Fourier, 75 013 PARIS", phone: '0606060606'
)
puts "Place #{orgSpip75place1.name} created"

agendaOrgSpip75place1 = Agenda.create!(place: orgSpip75place1, name: "Agenda SPIP 75")
puts "Agenda #{agenda3.name} created"

SlotFactory.perform

p 'Database seeded'
