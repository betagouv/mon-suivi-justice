require_relative '../seed_utils.rb'

org_tj_bordeaux = create_tj(name: 'TJ de Bordeaux')
org_spip_33_bordeaux = create_spip(name: 'SPIP 33 - Bordeaux', tjs: org_tj_bordeaux)

apt_type_sortie_audience_sap = AppointmentType.find_or_create_by!(name: "Sortie d'audience SAP")
apt_type_sortie_audience_spip = AppointmentType.find_or_create_by!(name: "Sortie d'audience SPIP")
apt_type_sap_ddse = AppointmentType.find_or_create_by!(name: "SAP DDSE")
apt_type_rdv_suivi_jap = AppointmentType.find_or_create_by!(name: 'Convocation de suivi JAP')
apt_type_rdv_suivi_spip = AppointmentType.find_or_create_by!(name: "Convocation de suivi SPIP")

place_spip_33_bordeaux = find_or_create_without_validation_by(Place, organization: org_spip_33_bordeaux, name: "SPIP de Bordeaux", adress: "37 Rue Général de Larminat, 33000 Bordeaux", phone: '+33606060606')
place_tj_bordeaux = find_or_create_without_validation_by(Place, organization: org_tj_bordeaux, name: "TJ de Bordeaux", adress: "30 Rue des Frères Bonie 33000 Bordeaux", phone: '+33606060606')


PlaceAppointmentType.find_or_create_by!(place: place_spip_33_bordeaux, appointment_type: apt_type_sortie_audience_spip)
PlaceAppointmentType.find_or_create_by!(place: place_spip_33_bordeaux, appointment_type: apt_type_rdv_suivi_spip)
PlaceAppointmentType.find_or_create_by!(place: place_spip_33_bordeaux, appointment_type: apt_type_sap_ddse)
PlaceAppointmentType.find_or_create_by!(place: place_tj_bordeaux, appointment_type: apt_type_sortie_audience_sap)
PlaceAppointmentType.find_or_create_by!(place: place_tj_bordeaux, appointment_type: apt_type_rdv_suivi_jap)

agenda_spip_bordeaux = Agenda.find_or_create_by!(place: place_spip_33_bordeaux, name: "Agenda SPIP Bordeaux")
agenda_tj_bordeaux = Agenda.find_or_create_by!(place: place_tj_bordeaux, name: "Agenda TJ Bordeaux")

slot_bdx_sap = Slot.create!(agenda: agenda_tj_bordeaux, starting_time: Time.zone.now, date: next_valid_day(day: :monday), duration: 15, capacity: 1, appointment_type: apt_type_sortie_audience_sap)
slot_bdx_spip = Slot.create!(agenda: agenda_spip_bordeaux, starting_time: Time.zone.now, date: next_valid_day(day: :tuesday), duration: 15, capacity: 1, appointment_type: apt_type_sortie_audience_spip)
slot_bdx_spip_suivi = Slot.create!(agenda: agenda_spip_bordeaux, starting_time: Time.zone.now, date: next_valid_day(day: :wednesday), appointment_type: apt_type_rdv_suivi_spip)

cpip_bdx = create_user(
  organization: org_spip_33_bordeaux, 
  email: 'cpip33bdx@example.com', 
  role: :cpip
)

create_user(
  organization: org_spip_33_bordeaux, 
  email: 'localadmin33bdx@example.com', 
  role: :local_admin
)

bex_bdx = create_user(
  organization: org_tj_bordeaux, 
  email: 'bextjbdx@example.com', 
  role: :bex
)

create_user(
  organization: org_tj_bordeaux,
  email: 'greffsap@example.com',
  role: :greff_sap
)

create_user(
  organization: org_tj_bordeaux, 
  email: 'localadmintjbdx@example.com', 
  role: :local_admin
)

create_user(
  organization: org_spip_33_bordeaux,
  email: 'overseer33bdx@example.com',
  role: :overseer
)

create_user(
  organization: org_spip_33_bordeaux,
  email: 'psy33bdx@example.com',
  role: :psychologist
)

SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_bordeaux, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sap_ddse, agenda: agenda_spip_bordeaux, week_day: :thursday, starting_time: Time.new(2021, 6, 21, 15, 00, 0), duration: 60, capacity: 5)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_bordeaux, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)

SlotFactory.perform

convict_bdx_1 = create_convict(organizations: [org_tj_bordeaux, org_spip_33_bordeaux])
convict_bdx_2 = create_convict(organizations: [org_tj_bordeaux, org_spip_33_bordeaux])
create_convict(organizations: [org_tj_bordeaux, org_spip_33_bordeaux])
create_convict(organizations: [org_tj_bordeaux, org_spip_33_bordeaux])

Appointment.create!(slot: slot_bdx_sap, convict: convict_bdx_1, inviter_user_id: bex_bdx.id).book(send_notification: false)
Appointment.create!(slot: slot_bdx_spip, convict: convict_bdx_1, inviter_user_id: bex_bdx.id).book(send_notification: false)
Appointment.create!(slot: slot_bdx_spip_suivi, convict: convict_bdx_2, inviter_user_id: cpip_bdx.id, user: cpip_bdx, creating_organization: org_spip_33_bordeaux).book(send_notification: false)
