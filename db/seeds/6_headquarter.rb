require_relative '../seed_utils.rb'

hq_spip_61 = Headquarter.find_or_create_by!(name: 'SPIP 61')

org_spip_61_argentan = create_spip(name: 'SPIP 61 - Argentan', headquarter: hq_spip_61)
org_spip_61_alencon = create_spip(name: 'SPIP 61 - Alençon', headquarter: hq_spip_61)

place_spip_61_argentan = find_or_create_without_validation_by(Place, organization: org_spip_61_argentan, name: "SPIP 61 - Argentan", adress: "17 avenue de l'Industrie, 61200 Argentan", phone: '+33606060606')
place_spip_61_alencon = find_or_create_without_validation_by(Place, organization: org_spip_61_alencon, name: "SPIP 61 - Alencon", adress: "4 Ter rue des Poulies, 61007 Alençon", phone: '+33606060606')

apt_type_rdv_suivi_spip = AppointmentType.find_or_create_by!(name: "Convocation de suivi SPIP")

PlaceAppointmentType.find_or_create_by!(place: place_spip_61_alencon, appointment_type: apt_type_rdv_suivi_spip)
PlaceAppointmentType.find_or_create_by!(place: place_spip_61_argentan, appointment_type: apt_type_rdv_suivi_spip)

Agenda.find_or_create_by!(place: place_spip_61_alencon, name: "Agenda Alencon")
Agenda.find_or_create_by!(place: place_spip_61_argentan, name: "Agenda Argentan")

create_user(
  organization: org_spip_61_argentan, email: 'cpip61argentan@example.com', role: :cpip,
  headquarter: hq_spip_61
)

create_user(
  organization: org_spip_61_argentan, email: 'localadmin61argentan@example.com', role: :local_admin,
  headquarter: hq_spip_61
)

create_user(
  organization: org_spip_61_alencon, email: 'cpip61alencon@example.com', role: :cpip,
)

create_user(
  organization: org_spip_61_alencon, email: 'localadmin61alencon@example.com', role: :local_admin,
)