FRENCH_DEPARTMENTS.each do |department|
  Department.find_or_create_by name: department.name, number: department.number
end

FRENCH_JURISDICTIONS.each do |name|
  Jurisdiction.find_or_create_by(name: name)
end

org_spip_92 = Organization.create!(name: 'SPIP 92', organization_type: 'spip')
org_tj_nanterre = Organization.create!(name: 'TJ Nanterre', organization_type: 'tj')
org_spip_75 = Organization.create!(name: 'SPIP 75', organization_type: 'spip')
org_spip_77 = Organization.create!(name: 'SPIP 77', organization_type: 'spip')
org_tj_melun = Organization.create!(name: 'TJ Melun', organization_type: 'tj')
org_tj_fontainebleau = Organization.create!(name: 'TJ de Fontainebleau', organization_type: 'tj')

# Un service peut être rattaché à des départements et/ou des juridictions
# Cela impacte le rattachement des ppsmj à tel  département et/ou juridiction à leur création
AreasOrganizationsMapping.create organization: org_spip_92, area: Department.find_by(number: '92')
AreasOrganizationsMapping.create organization: org_spip_92, area: Jurisdiction.find_by(name: 'TJ NANTERRE')
AreasOrganizationsMapping.create organization: org_tj_nanterre, area: Department.find_by(number: '92')

AreasOrganizationsMapping.create organization: org_spip_75, area: Department.find_by(number: '75')

AreasOrganizationsMapping.create organization: org_spip_77, area: Department.find_by(number: '77')
AreasOrganizationsMapping.create organization: org_spip_77, area: Jurisdiction.find_by(name: 'TJ MELUN')
AreasOrganizationsMapping.create organization: org_tj_melun, area: Department.find_by(number: '77')
AreasOrganizationsMapping.create organization: org_tj_fontainebleau, area: Department.find_by(number: '77')

convict_1 = Convict.create!(first_name: "Michel", last_name: "Blabla", phone: "0677777777", appi_uuid: "12345")
convict_2 = Convict.create!(first_name: "Dark", last_name: "Vador", phone: "0600000000", appi_uuid: "12346")
convict_3 = Convict.create!(first_name: "Bobba", last_name: "Smet", phone: "0611111111", appi_uuid: "12347")

AreasConvictsMapping.create convict: convict_1, area: Department.find_by(number: '92')
AreasConvictsMapping.create convict: convict_2, area: Department.find_by(number: '92')
AreasConvictsMapping.create convict: convict_2, area: Jurisdiction.find_by(name: 'TJ NANTERRE')
AreasConvictsMapping.create convict: convict_3, area: Department.find_by(number: '75')

User.create!(
        organization: org_spip_92, email: 'admin@example.com', password: '1mot2passeSecurise!',
        password_confirmation: '1mot2passeSecurise!', role: :admin, first_name: 'Kevin', last_name: 'McCallister'
      )

User.create!(
  organization: org_spip_92, email: 'cpip@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :cpip, first_name: 'Bob', last_name: 'Dupneu'
)

User.create!(
  organization: org_spip_75, email: 'cpip75@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :cpip, first_name: 'Luke', last_name: 'Skywalker'
)

User.create!(
  organization: org_spip_75, email: 'localadminSpip75@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :local_admin, first_name: 'Matthieu', last_name: 'Paris'
)

User.create!(
  organization: org_spip_92, email: 'localadminSpip92@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :local_admin, first_name: 'Henri', last_name: 'HautsDeSeine'
)

User.create!(
  organization: org_tj_nanterre, email: 'localadmintjnanterre@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :local_admin, first_name: 'André', last_name: 'Dussolier'
)

User.create!(
  organization: org_tj_melun, email: 'localadmintjmelun@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :local_admin, first_name: 'Michel', last_name: 'Melun'
)

User.create!(
  organization: org_tj_fontainebleau, email: 'localadmintjfontainebleau@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :local_admin, first_name: 'Robert', last_name: 'Fontaine'
)

User.create!(
  organization: org_spip_77, email: 'cpip77@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :cpip, first_name: 'Bruce', last_name: 'Wayne'
)

place_tj_nanterre = Place.create!(
  organization: org_tj_nanterre, name: "Tribunal judiciaire de Nanterre", adress: "179-191 av. Joliot Curie, 92020 NANTERRE", phone: '0606060606'
)

place_tj_melun = Place.create!(
  organization: org_tj_melun, name: "Tribunal judiciaire de Melun", adress: "2 Av. du Général Leclerc, 77010 Melun", phone: '0606060606'
)

place_tj_fontainebleau = Place.create!(
  organization: org_tj_fontainebleau, name: "Tribunal judiciaire de Fontainebleau", adress: "159 Rue Grande, 77300 Fontainebleau", phone: '0606060606'
)

place_spip_75 = Place.create!(
  organization: org_spip_75, name: "SPIP 75", adress: "12-14 rue Charles Fourier, 75013 PARIS", phone: '0606060606'
)

place_spip_77 = Place.create!(
  organization: org_spip_77, name: "SPIP 77", adress: "5 rue de la montagne du Mée, 77000 MELUN", phone: '0606060606'
)

place_spip_92 = Place.create!(organization: org_spip_92, name: "SPIP 92", adress: "94 Boulevard du Général Leclerc, 92000 Nanterre", phone: '0606060606')

agenda_tj_nanterre = Agenda.create!(place: place_tj_nanterre, name: "Agenda 1 tribunal Nanterre")
agenda_tj_nanterre_2 = Agenda.create!(place: place_tj_nanterre, name: "Agenda 2 tribunal Nanterre")

agenda_tj_melun = Agenda.create!(place: place_tj_melun, name: "Agenda 1 tribunal Melun")
agenda_tj_fontainebleau = Agenda.create!(place: place_tj_fontainebleau, name: "Agenda 1 tribunal Fontainebleau")

agenda_spip_75 = Agenda.create!(place: place_spip_75, name: "Agenda SPIP 75")
agenda_spip_92 = Agenda.create!(place: place_spip_92, name: "Agenda SPIP 92")

apt_type_sortie_audience_sap = AppointmentType.create!(name: "Sortie d'audience SAP")
apt_type_rdv_suivi_jap = AppointmentType.create!(name: 'RDV de suivi JAP')
apt_type_rdv_suivi_spip = AppointmentType.create!(name: "RDV de suivi SPIP")
apt_type_sortie_audience_spip = AppointmentType.create!(name: "Sortie d'audience SPIP")

PlaceAppointmentType.create!(place: place_tj_nanterre, appointment_type: apt_type_sortie_audience_sap)
PlaceAppointmentType.create!(place: place_tj_nanterre, appointment_type: apt_type_rdv_suivi_jap)
PlaceAppointmentType.create!(place: place_spip_92, appointment_type: apt_type_rdv_suivi_spip)
PlaceAppointmentType.create!(place: place_spip_92, appointment_type: apt_type_sortie_audience_spip)

PlaceAppointmentType.create!(place: place_tj_melun, appointment_type: apt_type_rdv_suivi_jap)
PlaceAppointmentType.create!(place: place_tj_melun, appointment_type: apt_type_sortie_audience_sap)
PlaceAppointmentType.create!(place: place_tj_fontainebleau, appointment_type: apt_type_rdv_suivi_jap)
PlaceAppointmentType.create!(place: place_tj_fontainebleau, appointment_type: apt_type_sortie_audience_sap)
PlaceAppointmentType.create!(place: place_spip_77, appointment_type: apt_type_sortie_audience_spip)

NotificationType.create!(appointment_type: apt_type_sortie_audience_sap, role: :summon, template: "Vous êtes convoqué, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_sap, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_sap, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_sap, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_sap, role: :reschedule, template: "Changement du rdv de date X a date Y.", is_default: true)

NotificationType.create!(appointment_type: apt_type_rdv_suivi_jap, role: :summon, template: "Vous êtes convoqué, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: apt_type_rdv_suivi_jap, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: apt_type_rdv_suivi_jap, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: apt_type_rdv_suivi_jap, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: apt_type_rdv_suivi_jap, role: :reschedule, template: "Changement du rdv de date X a date Y.", is_default: true)

NotificationType.create!(appointment_type: apt_type_rdv_suivi_spip, role: :summon, template: "Vous êtes convoqué, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: apt_type_rdv_suivi_spip, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: apt_type_rdv_suivi_spip, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: apt_type_rdv_suivi_spip, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: apt_type_rdv_suivi_spip, role: :reschedule, template: "Changement du rdv de date X a date Y.", is_default: true)

NotificationType.create!(appointment_type: apt_type_sortie_audience_spip, role: :summon, template: "Vous êtes convoqué à votre sortie d'audience SPIP, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_spip, role: :reminder, template: "RAPPEL Vous êtes convoqué à votre sortie d'audience SPIP, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_spip, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_spip, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_spip, role: :reschedule, template: "Changement du rdv de date X a date Y.", is_default: true)

SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_92, week_day: :monday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_92, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_nanterre, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_nanterre, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_melun, week_day: :monday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_fontainebleau, week_day: :tuesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)

SlotFactory.perform

p 'Database seeded'
