require 'faker'

hq_spip_61 = Headquarter.find_or_create_by!(name: 'SPIP 61')

org_spip_61_argentan = Organization.find_or_create_by!(name: 'SPIP 61 - Argentan', organization_type: 'spip', headquarter: hq_spip_61)
org_spip_61_alencon = Organization.find_or_create_by!(name: 'SPIP 61 - Alençon', organization_type: 'spip', headquarter: hq_spip_61)

place_spip_61_argentan = Place.find_or_create_by!(organization: org_spip_61_argentan, name: "SPIP 61 - Argentan", adress: "17 avenue de l'Industrie, 61200 Argentan", phone: '+33606060606')
place_spip_61_alencon = Place.find_or_create_by!(organization: org_spip_61_alencon, name: "SPIP 61 - Alencon", adress: "4 Ter rue des Poulies, 61007 Alençon", phone: '+33606060606')

apt_type_rdv_suivi_spip = AppointmentType.find_or_create_by!(name: "RDV de suivi SPIP")

PlaceAppointmentType.find_or_create_by!(place: place_spip_61_alencon, appointment_type: apt_type_rdv_suivi_spip)
PlaceAppointmentType.find_or_create_by!(place: place_spip_61_argentan, appointment_type: apt_type_rdv_suivi_spip)

Agenda.find_or_create_by!(place: place_spip_61_alencon, name: "Agenda Alencon")
Agenda.find_or_create_by!(place: place_spip_61_argentan, name: "Agenda Argentan")

User.find_or_create_by!(
  organization: org_spip_61_argentan, email: 'cpip61argentan@example.com', role: :cpip,
  headquarter: hq_spip_61
) do |user|
  user.password = '1mot2passeSecurise!'
  user.password_confirmation = '1mot2passeSecurise!'
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

User.find_or_create_by!(
  organization: org_spip_61_argentan, email: 'localadmin61argentan@example.com', role: :local_admin,
  headquarter: hq_spip_61
) do |user|
  user.password = '1mot2passeSecurise!'
  user.password_confirmation = '1mot2passeSecurise!'
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

User.find_or_create_by!(
  organization: org_spip_61_alencon, email: 'cpip61alencon@example.com', role: :cpip,
) do |user|
  user.password = '1mot2passeSecurise!'
  user.password_confirmation = '1mot2passeSecurise!'
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

User.find_or_create_by!(
  organization: org_spip_61_alencon, email: 'localadmin61alencon@example.com', role: :local_admin,
) do |user|
  user.password = '1mot2passeSecurise!'
  user.password_confirmation = '1mot2passeSecurise!'
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end