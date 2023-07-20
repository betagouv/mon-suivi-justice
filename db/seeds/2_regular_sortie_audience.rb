require_relative '../seed_utils.rb'

org_tj_bordeaux = create_tj(name: 'TJ de Bordeaux')
org_spip_33_bordeaux = create_spip(name: 'SPIP 33 - Bordeaux', tjs: org_tj_bordeaux)

place_spip_33_bordeaux = Place.find_or_create_by!(organization: org_spip_33_bordeaux, name: "SPIP de Bordeaux", adress: "37 Rue Général de Larminat, 33000 Bordeaux", phone: '+33606060606')
place_tj_bordeaux = Place.find_or_create_by!(organization: org_tj_bordeaux, name: "TJ de Bordeaux", adress: "30 Rue des Frères Bonie 33000 Bordeaux", phone: '+33606060606')

apt_type_sortie_audience_sap = AppointmentType.find_or_create_by!(name: "Sortie d'audience SAP")
apt_type_sortie_audience_spip = AppointmentType.find_or_create_by!(name: "Sortie d'audience SPIP")
apt_type_sap_ddse = AppointmentType.find_or_create_by!(name: "SAP DDSE")
apt_type_rdv_suivi_jap = AppointmentType.find_or_create_by!(name: 'Convocation de suivi JAP')
apt_type_rdv_suivi_spip = AppointmentType.find_or_create_by!(name: "Convocation de suivi SPIP")

PlaceAppointmentType.find_or_create_by!(place: place_spip_33_bordeaux, appointment_type: apt_type_sortie_audience_spip)
PlaceAppointmentType.find_or_create_by!(place: place_spip_33_bordeaux, appointment_type: apt_type_rdv_suivi_spip)
PlaceAppointmentType.find_or_create_by!(place: place_spip_33_bordeaux, appointment_type: apt_type_sap_ddse)
PlaceAppointmentType.find_or_create_by!(place: place_tj_bordeaux, appointment_type: apt_type_sortie_audience_sap)
PlaceAppointmentType.find_or_create_by!(place: place_tj_bordeaux, appointment_type: apt_type_rdv_suivi_jap)

agenda_spip_bordeaux = Agenda.find_or_create_by!(place: place_spip_33_bordeaux, name: "Agenda SPIP Bordeaux")
agenda_tj_bordeaux = Agenda.find_or_create_by!(place: place_tj_bordeaux, name: "Agenda TJ Bordeaux")

Slot.create!(agenda: agenda_tj_bordeaux, starting_time: Time.zone.now, date: Date.tomorrow.next_occurring(:monday), duration: 15, capacity: 1, appointment_type: apt_type_sortie_audience_sap)
Slot.create!(agenda: agenda_spip_bordeaux, starting_time: Time.zone.now, date: Date.tomorrow.next_occurring(:tuesday), duration: 15, capacity: 1, appointment_type: apt_type_sortie_audience_spip)

create_user(
  organization: org_spip_33_bordeaux, 
  email: 'cpip33bdx@example.com', 
  role: :cpip
)

create_user(
  organization: org_spip_33_bordeaux, 
  email: 'localadmin33bdx@example.com', 
  role: :local_admin
)

create_user(
  organization: org_tj_bordeaux, 
  email: 'bextjbdx@example.com', 
  role: :bex
)

create_user(
  organization: org_tj_bordeaux, 
  email: 'localadmintjbdx@example.com', 
  role: :local_admin
)

SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_bordeaux, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sap_ddse, agenda: agenda_spip_bordeaux, week_day: :thursday, starting_time: Time.new(2021, 6, 21, 15, 00, 0), duration: 60, capacity: 5)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_bordeaux, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)

SlotFactory.perform

create_convict(organizations: [org_tj_bordeaux, org_spip_33_bordeaux])
create_convict(organizations: [org_tj_bordeaux, org_spip_33_bordeaux])
create_convict(organizations: [org_tj_bordeaux, org_spip_33_bordeaux])
create_convict(organizations: [org_tj_bordeaux, org_spip_33_bordeaux])
