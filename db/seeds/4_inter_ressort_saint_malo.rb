require_relative '../seed_utils.rb'

org_tj_st_brieuc = create_tj(name: 'TJ St Brieuc', use_inter_ressort: true)
org_tj_st_malo = create_tj(name: 'TJ St Malo', use_inter_ressort: true)
org_spip_22_st_brieuc = create_spip(name: 'SPIP 22 - St Brieuc', tjs: [org_tj_st_brieuc, org_tj_st_malo])
org_spip_22_guingamp = create_spip(name: 'SPIP 22 - Guingamp', tjs: [org_tj_st_brieuc])

srj_spip_st_brieuc = SrjSpip.find_or_create_by!(name: "Antenne de Saint-Brieuc du Service Pénitentiaire d'Insertion et de Probation des Côtes d'Armor", organization: org_spip_22_st_brieuc)
srj_tj_st_brieuc = SrjTj.find_or_create_by!(name: "Tribunal judiciaire de Saint-Brieuc", organization: org_tj_st_brieuc)
st_brieuc = City.find_or_create_by!(name: 'Saint-Brieuc', zipcode: '22000', code_insee: '22278', city_id: '41783', srj_tj: srj_tj_st_brieuc, srj_spip: srj_spip_st_brieuc)

srj_tj_st_malo = SrjTj.find_or_create_by!(name: "Tribunal judiciaire de Saint-Malo", organization: org_tj_st_malo)
st_malo = City.find_or_create_by!(name: 'Saint-Malo', zipcode: '35400', code_insee: '35288', city_id: '42431', srj_tj: srj_tj_st_malo)

srj_spip_guingamp = SrjSpip.find_or_create_by!(name: "Antenne de Guingamp du Service Pénitentiaire d'Insertion et de Probation des Côtes d'Armor", organization: org_spip_22_guingamp)
City.find_or_create_by!(name: 'Guingamp', zipcode: '22200', code_insee: '22070', city_id: '41556', srj_tj: srj_tj_st_brieuc, srj_spip: srj_spip_guingamp)

place_spip_22_st_brieuc = find_or_create_without_validation_by(Place,organization: org_spip_22_st_brieuc, name: "SPIP St Brieuc", adress: "30 Rue de Paris, 22000 Saint-Brieuc", phone: '+33606060606')
place_tj_st_brieuc = find_or_create_without_validation_by(Place,organization: org_tj_st_brieuc, name: "TJ St Brieuc", adress: "2 Bd de Sévigné, 22000 Saint-Brieuc", phone: '+33606060606')
place_tj_st_malo = find_or_create_without_validation_by(Place,organization: org_tj_st_malo, name: "TJ St Malo", adress: "49 AVENUE ARISTIDE BRIAND CS 51731 35417 St malo", phone: '+33606060606')

apt_type_sortie_audience_sap = AppointmentType.find_or_create_by!(name: "Sortie d'audience SAP")
apt_type_sortie_audience_spip = AppointmentType.find_or_create_by!(name: "Sortie d'audience SPIP")

PlaceAppointmentType.find_or_create_by!(place: place_spip_22_st_brieuc, appointment_type: apt_type_sortie_audience_spip)
PlaceAppointmentType.find_or_create_by!(place: place_tj_st_brieuc, appointment_type: apt_type_sortie_audience_sap)
PlaceAppointmentType.find_or_create_by!(place: place_tj_st_malo, appointment_type: apt_type_sortie_audience_sap)

agenda_spip_st_brieuc = Agenda.find_or_create_by!(place: place_spip_22_st_brieuc, name: "Agenda SPIP St Brieuc")
agenda_tj_st_brieuc = Agenda.find_or_create_by!(place: place_tj_st_brieuc, name: "Agenda TJ St Brieuc")
agenda_tj_st_malo = Agenda.find_or_create_by!(place: place_tj_st_malo, name: "Agenda TJ St Malo")

slot_tj_st_brieuc = Slot.create!(agenda: agenda_tj_st_brieuc, starting_time: Time.zone.now, date: next_valid_day(day: :monday), duration: 15, capacity: 1, appointment_type: apt_type_sortie_audience_sap)
slot_tj_st_malo = Slot.create!(agenda: agenda_tj_st_malo, starting_time: Time.zone.now, date: next_valid_day(day: :monday), duration: 15, capacity: 1, appointment_type: apt_type_sortie_audience_sap)
slot_spip_22 = Slot.create!(agenda: agenda_spip_st_brieuc, starting_time: Time.zone.now, date: next_valid_day(day: :tuesday), duration: 15, capacity: 1, appointment_type: apt_type_sortie_audience_spip)

cpip_22 = create_user(organization: org_spip_22_st_brieuc, email: 'cpip22stbrieuc@example.com', role: :cpip)
create_user(organization: org_spip_22_st_brieuc, email: 'localadmin22stbrieuc@example.com', role: :local_admin)

bex_tj_st_brieuc = create_user(organization: org_tj_st_brieuc, email: 'bexstbrieuc@example.com', role: :bex)
create_user(organization: org_tj_st_brieuc, email: 'localadmintjstbrieuc@example.com', role: :local_admin)
create_user(organization: org_tj_st_brieuc, email: 'greffsaptjstbrieuc@example.com', role: :greff_sap)

bex_tj_st_malo = create_user(organization: org_tj_st_malo, email: 'bexstmalo@example.com', role: :bex)
create_user(organization: org_tj_st_malo, email: 'localadmintjstmalo@example.com', role: :local_admin)
create_user(organization: org_tj_st_malo, email: 'greffsaptjstmalo@example.com', role: :greff_sap)

cpip_guingamp = create_user(organization: org_spip_22_guingamp, email: 'cpipguingamp@example.com', role: :cpip)

convict_st_brieuc = create_convict(organizations: [org_tj_st_brieuc, org_spip_22_st_brieuc, org_tj_st_malo], city: st_brieuc)
convict_st_malo = create_convict(organizations: [org_tj_st_brieuc, org_spip_22_st_brieuc, org_tj_st_malo], city: st_malo)

Appointment.create!(slot: slot_tj_st_brieuc, convict: convict_st_brieuc, inviter_user_id: bex_tj_st_brieuc.id).book(send_notification: false)
Appointment.create!(slot: slot_spip_22, convict: convict_st_brieuc, inviter_user_id: cpip_22.id).book(send_notification: false)
Appointment.create!(slot: slot_tj_st_malo, convict: convict_st_malo, inviter_user_id: bex_tj_st_malo.id).book(send_notification: false)

