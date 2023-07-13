ApplicationRecord.reset_column_information

FRENCH_DEPARTMENTS.each do |department|
  Department.find_or_create_by name: department.name, number: department.number
end

FRENCH_JURISDICTIONS.each do |name|
  Jurisdiction.find_or_create_by(name: name)
end

hq_spip_61 = Headquarter.create!(name: 'SPIP 61')
org_spip_92 = Organization.create!(name: 'SPIP 92', organization_type: 'spip')
org_spip_61_argentan = Organization.create!(name: 'SPIP 61 - Argentan', organization_type: 'spip', headquarter: hq_spip_61)
org_spip_61_alencon = Organization.create!(name: 'SPIP 61 - Alençon', organization_type: 'spip', headquarter: hq_spip_61)
org_tj_nanterre = Organization.create!(name: 'TJ Nanterre', organization_type: 'tj', jap_modal_content: '<b>Pouet</b>')
org_spip_75 = Organization.create!(name: 'SPIP 75', organization_type: 'spip')
org_spip_77 = Organization.create!(name: 'SPIP 77', organization_type: 'spip')
org_tj_melun = Organization.create!(name: 'TJ Melun', organization_type: 'tj')
org_tj_fontainebleau = Organization.create!(name: 'TJ de Fontainebleau', organization_type: 'tj')
org_tj_paris = Organization.create!(name: 'TJ Paris', organization_type: 'tj')


convict_1 = Convict.create!(first_name: "Michel", last_name: "Blabla", phone: "0677777777", appi_uuid: "12345", date_of_birth: "02/01/1986", organizations: [org_spip_92])
convict_2 = Convict.create!(first_name: "Dark", last_name: "Vador", phone: "0600000000", appi_uuid: "12346", date_of_birth: "02/01/1986", organizations: [org_spip_92, org_tj_nanterre])
convict_3 = Convict.create!(first_name: "Bobba", last_name: "Smet", phone: "0611111111", appi_uuid: "12347", date_of_birth: "02/01/1986", organizations: [org_spip_75])
convict_4 = Convict.create!(first_name: "Conor", last_name: "McGregor", phone: "0611111112", appi_uuid: "12348", date_of_birth: "02/01/1986", organizations: [org_spip_77, org_tj_melun])
convict_5 = Convict.create!(first_name: "Georges", last_name: "Saint-Pierre", phone: "0611111113", appi_uuid: "12349", date_of_birth: "02/01/1986", organizations: [org_spip_77, org_tj_fontainebleau])
convict_6 = Convict.create!(first_name: "John", last_name: "Jones", no_phone: true, appi_uuid: "123410", organizations: [org_spip_92, org_tj_nanterre], date_of_birth: "02/01/1986")
convict_7 = Convict.create!(first_name: "Dark", last_name: "Vador", no_phone: true, appi_uuid: "123411", organizations: [org_spip_92, org_tj_nanterre], date_of_birth: "02/01/1986")

User.create!(
  organization: org_spip_92, email: 'admin@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :admin, first_name: 'Kevin', last_name: 'McCallister'
)

User.create!(
  organization: org_spip_92, email: 'cpip@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :cpip, first_name: 'Bob', last_name: 'Dupneu'
)

User.create!(
  organization: org_spip_61_argentan, email: 'cpip61argentan@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :cpip, first_name: 'Sylvain', last_name: 'Chabrier',
  headquarter: hq_spip_61
)

User.create!(
  organization: org_spip_61_argentan, email: 'localadmin61argentan@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :local_admin, first_name: 'Jacques', last_name: 'Chirac',
  headquarter: hq_spip_61
)

User.create!(
  organization: org_spip_61_alencon, email: 'cpip61alencon@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :cpip, first_name: 'Tom', last_name: 'Aouate'
)

User.create!(
  organization: org_spip_61_alencon, email: 'localadmin61alencon@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :local_admin, first_name: 'François', last_name: 'Hollande'
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
  organization: org_tj_nanterre, email: 'bexnanterre@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :bex, first_name: 'Max', last_name: 'Verstappen'
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
  organization: org_tj_fontainebleau, email: 'bextjfontainebleau@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :bex, first_name: 'Cyril', last_name: 'Gane'
)

User.create!(
  organization: org_spip_77, email: 'localadminSpip77@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :local_admin, first_name: 'Flash', last_name: 'McQueen'
)

User.create!(
  organization: org_spip_77, email: 'cpip77@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :cpip, first_name: 'Henri', last_name: 'Vasnier'
)

User.create!(
  organization: org_tj_melun, email: 'bextjmelun@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :bex, first_name: 'Roger', last_name: 'Federer'
)

User.create!(
  organization: org_tj_paris, email: 'bextjparis@example.com', password: '1mot2passeSecurise!',
  password_confirmation: '1mot2passeSecurise!', role: :bex, first_name: 'Stanislas', last_name: 'Wawrinka'
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

place_spip_77_permanence_tj = Place.create!(
  organization: org_spip_77, name: "Permanence TJ Fontainebleau", adress: "5 rue de la montagne du Mée, 77000 MELUN", phone: '0606060606'
)

place_spip_92 = Place.create!(organization: org_spip_92, name: "SPIP 92", adress: "94 Boulevard du Général Leclerc, 92000 Nanterre", phone: '0606060606')

place_spip_61_argentan = Place.create!(organization: org_spip_61_argentan, name: "SPIP 61 - Argentan", adress: "17 avenue de l'Industrie, 61200 Argentan", phone: '0606060606')
place_spip_61_alencon = Place.create!(organization: org_spip_61_alencon, name: "SPIP 61 - Alencon", adress: "4 Ter rue des Poulies, 61007 Alençon", phone: '0606060606')

agenda_tj_nanterre = Agenda.create!(place: place_tj_nanterre, name: "Agenda 1 tribunal Nanterre")
agenda_tj_nanterre_2 = Agenda.create!(place: place_tj_nanterre, name: "Agenda 2 tribunal Nanterre")

agenda_tj_melun = Agenda.create!(place: place_tj_melun, name: "Agenda 1 tribunal Melun")
agenda_tj_fontainebleau = Agenda.create!(place: place_tj_fontainebleau, name: "Agenda 1 tribunal Fontainebleau")

agenda_spip_75 = Agenda.create!(place: place_spip_75, name: "Agenda SPIP 75")
agenda_spip_92 = Agenda.create!(place: place_spip_92, name: "Agenda SPIP 92")
agenda_spip_77 = Agenda.create!(place: place_spip_77, name: "Agenda SPIP 77")
agenda_spip_77_permanence_tj = Agenda.create!(place: place_spip_77_permanence_tj, name: "Permanence TJ Fontainebleau")
agenda_spip_77_permanence_tj_2 = Agenda.create!(place: place_spip_77_permanence_tj, name: "Permanence TJ Fontainebleau 2")

apt_type_sortie_audience_sap = AppointmentType.create!(name: "Sortie d'audience SAP")
apt_type_convocation_suivi_jap = AppointmentType.create!(name: 'Convocation de suivi JAP')
apt_type_convocation_suivi_spip = AppointmentType.create!(name: "Convocation de suivi SPIP")
apt_type_sortie_audience_spip = AppointmentType.create!(name: "Sortie d'audience SPIP")
apt_type_sap_ddse = AppointmentType.create!(name: "SAP DDSE")

PlaceAppointmentType.create!(place: place_tj_nanterre, appointment_type: apt_type_sortie_audience_sap)
PlaceAppointmentType.create!(place: place_tj_nanterre, appointment_type: apt_type_convocation_suivi_jap)
PlaceAppointmentType.create!(place: place_spip_92, appointment_type: apt_type_convocation_suivi_spip)
PlaceAppointmentType.create!(place: place_spip_61_alencon, appointment_type: apt_type_convocation_suivi_spip)
PlaceAppointmentType.create!(place: place_spip_61_argentan, appointment_type: apt_type_convocation_suivi_spip)
PlaceAppointmentType.create!(place: place_spip_92, appointment_type: apt_type_sortie_audience_spip)
PlaceAppointmentType.create!(place: place_spip_92, appointment_type: apt_type_sap_ddse)

PlaceAppointmentType.create!(place: place_tj_melun, appointment_type: apt_type_convocation_suivi_jap)
PlaceAppointmentType.create!(place: place_tj_melun, appointment_type: apt_type_sortie_audience_sap)
PlaceAppointmentType.create!(place: place_tj_fontainebleau, appointment_type: apt_type_convocation_suivi_jap)
PlaceAppointmentType.create!(place: place_tj_fontainebleau, appointment_type: apt_type_sortie_audience_sap)
PlaceAppointmentType.create!(place: place_spip_77, appointment_type: apt_type_sortie_audience_spip)
PlaceAppointmentType.create!(place: place_spip_77_permanence_tj, appointment_type: apt_type_sortie_audience_spip)

NotificationType.create!(appointment_type: apt_type_sortie_audience_sap, role: :summon, template: "Vous êtes convoqué, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_sap, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_sap, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_sap, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_sap, role: :reschedule, template: "Changement de la convocation de date X a date Y.", is_default: true)

NotificationType.create!(appointment_type: apt_type_convocation_suivi_jap, role: :summon, template: "Vous êtes convoqué, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: apt_type_convocation_suivi_jap, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: apt_type_convocation_suivi_jap, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: apt_type_convocation_suivi_jap, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: apt_type_convocation_suivi_jap, role: :reschedule, template: "Changement de la convocation de date X a date Y.", is_default: true)

NotificationType.create!(appointment_type: apt_type_convocation_suivi_spip, role: :summon, template: "Vous êtes convoqué, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: apt_type_convocation_suivi_spip, role: :reminder, template: "RAPPEL Vous êtes convoqué, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: apt_type_convocation_suivi_spip, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: apt_type_convocation_suivi_spip, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: apt_type_convocation_suivi_spip, role: :reschedule, template: "Changement de la convocation de date X a date Y.", is_default: true)

NotificationType.create!(appointment_type: apt_type_sortie_audience_spip, role: :summon, template: "Vous êtes convoqué à votre sortie d'audience SPIP, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_spip, role: :reminder, template: "RAPPEL Vous êtes convoqué à votre sortie d'audience SPIP, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_spip, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_spip, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: apt_type_sortie_audience_spip, role: :reschedule, template: "Changement de la convocation de date X a date Y.", is_default: true)

NotificationType.create!(appointment_type: apt_type_sap_ddse, role: :summon, template: "Vous êtes convoqué à votre rdv SAP DDSE, merci de venir.", is_default: true)
NotificationType.create!(appointment_type: apt_type_sap_ddse, role: :reminder, template: "RAPPEL Vous êtes convoqué à votre rdv SAP DDSE, vraiment il faut venir.", reminder_period: :two_days, is_default: true)
NotificationType.create!(appointment_type: apt_type_sap_ddse, role: :cancelation, template: "Finalement non, c'est pas la peine.", is_default: true)
NotificationType.create!(appointment_type: apt_type_sap_ddse, role: :no_show, template: "Vous n'êtes pas venu :(", is_default: true)
NotificationType.create!(appointment_type: apt_type_sap_ddse, role: :reschedule, template: "Changement de la convocation de date X a date Y.", is_default: true)

SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_92, week_day: :monday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_92, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sap_ddse, agenda: agenda_spip_92, week_day: :thursday, starting_time: Time.new(2021, 6, 21, 15, 00, 0), duration: 60, capacity: 5)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_nanterre, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_nanterre_2, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_melun, week_day: :monday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_fontainebleau, week_day: :tuesday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_77, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_77_permanence_tj, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_77_permanence_tj_2, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)

SlotFactory.perform

p 'Database seeded'
