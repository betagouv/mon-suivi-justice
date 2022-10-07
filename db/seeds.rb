FRENCH_DEPARTMENTS.each do |department|
  Department.find_or_create_by name: department.name, number: department.number
end

FRENCH_JURISDICTIONS.each do |name|
  Jurisdiction.find_or_create_by(name: name)
end

org_spip_92 = Organization.create!(name: 'SPIP 92', organization_type: 'spip')

org_tj_nanterre = Organization.create!(name: 'TJ Nanterre', organization_type: 'tj')

org_spip_75 = Organization.create!(name: 'SPIP 75', organization_type: 'spip')

# Un service peut être rattaché à des départements et/ou des juridictions
# Cela impacte le rattachement des ppsmj à tel  département et/ou juridiction à leur création
AreasOrganizationsMapping.create organization: org_spip_92, area: Department.find_by(number: '92')
AreasOrganizationsMapping.create organization: org_spip_92, area: Jurisdiction.find_by(name: 'TJ NANTERRE')
AreasOrganizationsMapping.create organization: org_tj_nanterre, area: Department.find_by(number: '92')
AreasOrganizationsMapping.create organization: org_spip_75, area: Department.find_by(number: '75')

convict_1 = Convict.create!(first_name: "Michel", last_name: "Blabla", phone: "0677777777", appi_uuid: "12345")
convict_2 = Convict.create!(first_name: "Dark", last_name: "Vador", phone: "0600000000", appi_uuid: "12346")

AreasConvictsMapping.create convict: convict_1, area: Department.find_by(number: '92')
AreasConvictsMapping.create convict: convict_2, area: Department.find_by(number: '92')
AreasConvictsMapping.create convict: convict_2, area: Jurisdiction.find_by(name: 'TJ NANTERRE')

admin = User.create!(
        organization: org_spip_92, email: 'admin@example.com', password: '1mot2passeSecurise!',
        password_confirmation: '1mot2passeSecurise!', role: :admin, first_name: 'Kevin', last_name: 'McCallister'
      )

cpip = User.create!(
  organization: org_spip_92, email: 'cpip@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :cpip, first_name: 'Bob', last_name: 'Dupneu'
)

cpip2 = User.create!(
  organization: org_spip_75, email: 'cpip75@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :cpip, first_name: 'Luke', last_name: 'Skywalker'
)

local_admin_spip_75 = User.create!(
  organization: org_spip_75, email: 'localadminSpip75@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :local_admin, first_name: 'Shia', last_name: 'Leboeuf'
)

local_admin_tj_nanterre = User.create!(
  organization: org_tj_nanterre, email: 'localadmintjnanterre@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :local_admin, first_name: 'André', last_name: 'Dussolier'
)

place_1 = Place.create!(
  organization: org_tj_nanterre, name: "Tribunal judiciaire de Nanterre", adress: "179-191 av. Joliot Curie, 92020 NANTERRE", phone: '0606060606'
)

agenda_1 = Agenda.create!(place: place_1, name: "Agenda 1 tribunal Nanterre")
agenda_2 = Agenda.create!(place: place_1, name: "Agenda 2 tribunal Nanterre")
appointment_type_1 = AppointmentType.create!(name: "Sortie d'audience SAP")
appointment_type_2 = AppointmentType.create!(name: 'RDV de suivi JAP')
PlaceAppointmentType.create!(place: place_1, appointment_type: appointment_type_1)
PlaceAppointmentType.create!(place: place_1, appointment_type: appointment_type_2)

NotificationType.create!(appointment_type: appointment_type_1, role: :summon, template: "Vous êtes convoqué, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: appointment_type_1, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: appointment_type_1, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: appointment_type_1, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: appointment_type_1, role: :reschedule, template: "Changement du rdv de date X a date Y.", is_default: true)
NotificationType.create!(appointment_type: appointment_type_2, role: :summon, template: "Vous êtes convoqué, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: appointment_type_2, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: appointment_type_2, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: appointment_type_2, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: appointment_type_2, role: :reschedule, template: "Changement du rdv de date X a date Y.", is_default: true)

SlotType.create(appointment_type: appointment_type_1, agenda: agenda_1, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type_1, agenda: agenda_1, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)

place_2 = Place.create!(organization: org_spip_92, name: "SPIP 92", adress: "94 Boulevard du Général Leclerc, 92000 Nanterre", phone: '0606060606')
agenda_3 = Agenda.create!(place: place_2, name: "Agenda SPIP 92")

appointment_type_3 = AppointmentType.create!(name: "RDV de suivi SPIP")
PlaceAppointmentType.create!(place: place_2, appointment_type: appointment_type_3)

NotificationType.create!(appointment_type: appointment_type_3, role: :summon, template: "Vous êtes convoqué, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: appointment_type_3, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: appointment_type_3, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: appointment_type_3, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: appointment_type_3, role: :reschedule, template: "Changement du rdv de date X a date Y.", is_default: true)

appointment_type_4 = AppointmentType.create!(name: "Sortie d'audience SPIP")
PlaceAppointmentType.create!(place: place_2, appointment_type: appointment_type_4)
NotificationType.create!(appointment_type: appointment_type_4, role: :summon, template: "Vous êtes convoqué à votre sortie d'audience SPIP, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: appointment_type_4, role: :reminder, template: "RAPPEL Vous êtes convoqué à votre sortie d'audience SPIP, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: appointment_type_4, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: appointment_type_4, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: appointment_type_4, role: :reschedule, template: "Changement du rdv de date X a date Y.", is_default: true)

SlotType.create(appointment_type: appointment_type_4, agenda: agenda_3, week_day: :monday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: appointment_type_4, agenda: agenda_3, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)

org_spip_75_place_1 = Place.create!(
  organization: org_spip_75, name: "SPIP 75", adress: "12-14 rue Charles Fourier, 75 013 PARIS", phone: '0606060606'
)

agenda_org_spip_75_place_1 = Agenda.create!(place: org_spip_75_place_1, name: "Agenda SPIP 75")

SlotFactory.perform

p 'Database seeded'
