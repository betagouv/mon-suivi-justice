require_relative '../seed_utils.rb'

org_tj_pontoise = create_tj(name: 'TJ Pontoise', use_inter_ressort: true)
org_tj_versailles = create_tj(name: 'TJ Versailles', use_inter_ressort: true)
org_tj_nanterre = create_tj(name: 'TJ Nanterre', use_inter_ressort: true)
org_tj_chartres = create_tj(name: 'TJ Chartres', use_inter_ressort: true)

org_spip_95 = create_spip(name: "SPIP 95", tjs: org_tj_pontoise)
org_spip_92 = create_spip(name: "SPIP 92", tjs: org_tj_nanterre)
org_spip_28 = create_spip(name: "SPIP 28", tjs: org_tj_chartres)
org_spip_78 = create_spip(name: "SPIP 78", tjs: org_tj_versailles)

srj_spip_95 = SrjSpip.find_or_create_by!(name: "Service Pénitentiaire d'Insertion et de Probation du Val d'Oise", organization: org_spip_95)
srj_spip_78 = SrjSpip.find_or_create_by!(name: "Antenne de Versailles-Bois-d'Arcy du Service Pénitentiaire d'Insertion et de Probation des Yvelines", organization: org_spip_78)
srj_spip_28 = SrjSpip.find_or_create_by!(name: "Antenne de Chartres du Service Pénitentiaire d'Insertion et de Probation d'Eure-et-Loir", organization: org_spip_28)
srj_spip_92 = SrjSpip.find_or_create_by!(name: "Service Pénitentiaire d'Insertion et de Probation des Hauts-de-Seine", organization: org_spip_92)

srj_tj_pontoise = SrjTj.find_or_create_by!(name: "Tribunal judiciaire de Pontoise", organization: org_tj_pontoise)
srj_tj_versailles = SrjTj.find_or_create_by!(name: "Tribunal judiciaire de Versailles", organization: org_tj_versailles)
srj_tj_chartres = SrjTj.find_or_create_by!(name: "Tribunal judiciaire de Chartres", organization: org_tj_chartres)
srj_tj_nanterre = SrjTj.find_or_create_by!(name: "Tribunal judiciaire de Nanterre", organization: org_tj_nanterre)

pontoise = City.find_or_create_by!(name: 'Pontoise', zipcode: '95000', code_insee: '95500', city_id: '95607', srj_tj: srj_tj_pontoise, srj_spip: srj_spip_95)
versailles = City.find_or_create_by!(name: 'Versailles', zipcode: '78000', code_insee: '78646', city_id: '78646', srj_tj: srj_tj_versailles, srj_spip: srj_spip_78)
chartres = City.find_or_create_by!(name: 'Chartres', zipcode: '28000', code_insee: '28085', city_id: '28085', srj_tj: srj_tj_chartres, srj_spip: srj_spip_28)
nanterre = City.find_or_create_by!(name: 'Nanterre', zipcode: '92000', code_insee: '92050', city_id: '92050', srj_tj: srj_tj_nanterre, srj_spip: srj_spip_92)


place_tj_pontoise = find_or_create_without_validation_by(Place, organization: org_tj_pontoise, name: "TJ Pontoise", adress: "3 Rue Victor Hugo, 95300 Pontoise", phone: '+33606060606')
place_tj_versailles = find_or_create_without_validation_by(Place, organization: org_tj_versailles, name: "TJ Versailles", adress: "5 Rue Carnot, 78000 Versailles", phone: '+33606060606')
place_tj_chartres = find_or_create_without_validation_by(Place, organization: org_tj_chartres, name: "TJ Chartres", adress: "1 Rue Saint-Jacques, 28000 Chartres", phone: '+33606060606')
place_tj_nanterre = find_or_create_without_validation_by(Place, organization: org_tj_nanterre, name: "TJ Nanterre", adress: "179-191 Avenue Joliot Curie, 92000 Nanterre", phone: '+33606060606')

place_spip_92 = find_or_create_without_validation_by(Place, organization: org_spip_92, name: "SPIP 92", adress: "179-191 Avenue Joliot Curie, 92000 Nanterre", phone: '+33606060606')
place_spip_28 = find_or_create_without_validation_by(Place, organization: org_spip_28, name: "SPIP 28", adress: "1 Rue Saint-Jacques, 28000 Chartres", phone: '+33606060606')
place_spip_95 = find_or_create_without_validation_by(Place, organization: org_spip_95, name: "SPIP 95", adress: "3 Rue Victor Hugo, 95300 Pontoise", phone: '+33606060606')
place_spip_78 = find_or_create_without_validation_by(Place, organization: org_spip_78, name: "SPIP 78", adress: "5 Rue Carnot, 78000 Versailles", phone: '+33606060606')

apt_type_sortie_audience_sap = AppointmentType.find_or_create_by!(name: "Sortie d'audience SAP")
apt_type_sortie_audience_spip = AppointmentType.find_or_create_by!(name: "Sortie d'audience SPIP")

PlaceAppointmentType.find_or_create_by!(place: place_tj_pontoise, appointment_type: apt_type_sortie_audience_sap)
PlaceAppointmentType.find_or_create_by!(place: place_tj_versailles, appointment_type: apt_type_sortie_audience_sap)
PlaceAppointmentType.find_or_create_by!(place: place_tj_chartres, appointment_type: apt_type_sortie_audience_sap)
PlaceAppointmentType.find_or_create_by!(place: place_tj_nanterre, appointment_type: apt_type_sortie_audience_sap)

PlaceAppointmentType.find_or_create_by!(place: place_spip_92, appointment_type: apt_type_sortie_audience_spip)
PlaceAppointmentType.find_or_create_by!(place: place_spip_28, appointment_type: apt_type_sortie_audience_spip)
PlaceAppointmentType.find_or_create_by!(place: place_spip_95, appointment_type: apt_type_sortie_audience_spip)
PlaceAppointmentType.find_or_create_by!(place: place_spip_78, appointment_type: apt_type_sortie_audience_spip)

agenda_tj_pontoise = Agenda.find_or_create_by!(place: place_tj_pontoise, name: "Agenda TJ Pontoise")
agenda_tj_versailles = Agenda.find_or_create_by!(place: place_tj_versailles, name: "Agenda TJ Versailles")
agenda_tj_chartres = Agenda.find_or_create_by!(place: place_tj_chartres, name: "Agenda TJ Chartres")
agenda_tj_nanterre = Agenda.find_or_create_by!(place: place_tj_nanterre, name: "Agenda TJ Nanterre")

agenda_spip_92 = Agenda.find_or_create_by!(place: place_spip_92, name: "Agenda SPIP 92")
agenda_spip_28 = Agenda.find_or_create_by!(place: place_spip_28, name: "Agenda SPIP 28")
agenda_spip_95 = Agenda.find_or_create_by!(place: place_spip_95, name: "Agenda SPIP 95")
agenda_spip_78 = Agenda.find_or_create_by!(place: place_spip_78, name: "Agenda SPIP 78")

slot_tj_pontoise = Slot.create(agenda: agenda_tj_pontoise, starting_time: Time.zone.now, date: next_valid_day(day: :monday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_sap)
slot_tj_versailles = Slot.create(agenda: agenda_tj_versailles, starting_time: Time.zone.now, date: next_valid_day(day: :monday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_sap)
slot_tj_nanterre = Slot.create(agenda: agenda_tj_nanterre, starting_time: Time.zone.now, date: next_valid_day(day: :monday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_sap)
slot_tj_chartres = Slot.create(agenda: agenda_tj_chartres, starting_time: Time.zone.now, date: next_valid_day(day: :monday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_sap)

slot_spip_92 = Slot.create(agenda: agenda_spip_92, starting_time: Time.zone.now, date: next_valid_day(day: :tuesday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_spip)
slot_spip_78 = Slot.create(agenda: agenda_spip_78, starting_time: Time.zone.now, date: next_valid_day(day: :tuesday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_spip)
slot_spip_28 = Slot.create(agenda: agenda_spip_28, starting_time: Time.zone.now, date: next_valid_day(day: :tuesday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_spip)
slot_spip_95 = Slot.create(agenda: agenda_spip_95, starting_time: Time.zone.now, date: next_valid_day(day: :tuesday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_spip)

bex_pontoise = create_user(organization: org_tj_pontoise, role: :bex, email:'bextjpontoise@example.com')
bex_versailles = create_user(organization: org_tj_versailles, role: :bex, email: 'bextjversailles@example.com')
bex_chartres = create_user(organization: org_tj_chartres, role: :bex, email: 'bextjchartres@example.com')
bex_nanterre = create_user(organization: org_tj_nanterre, role: :bex, email: 'bextjnanterre@example.com')

create_user(organization: org_tj_pontoise, email: 'greffsappontoise@example.com', role: :greff_sap)
create_user(organization: org_tj_versailles, email: 'greffsapversailles@example.com', role: :greff_sap)
create_user(organization: org_tj_chartres, email: 'greffsapchartres@example.com', role: :greff_sap)
create_user(organization: org_tj_nanterre, email: 'greffsapnanterre@example.com', role: :greff_sap)

create_user(organization: org_tj_pontoise, email: 'localadminpontoise@example.com', role: :local_admin)
create_user(organization: org_tj_versailles, email: 'localadminversailles@example.com', role: :local_admin)
create_user(organization: org_tj_chartres, email: 'localadminchartres@example.com', role: :local_admin)
create_user(organization: org_tj_nanterre, email: 'localadminnanterre@example.com', role: :local_admin)

cpip_95 = create_user(organization: org_spip_95, role: :cpip, email: 'cpip95@example.com')
cpip_78 = create_user(organization: org_spip_78, role: :cpip, email: 'cpip78@example.com')
cpip_28 = create_user(organization: org_spip_28, role: :cpip, email: 'cpip28@example.com')
cpip_92 = create_user(organization: org_spip_92, role: :cpip, email: 'cpip92@example.com')

create_user(organization: org_spip_95, role: :local_admin, email: 'localadmin95@example.com')
create_user(organization: org_spip_78, role: :local_admin, email: 'localadmin78@example.com')
create_user(organization: org_spip_28, role: :local_admin, email: 'localadmin28@example.com')
create_user(organization: org_spip_92, role: :local_admin, email: 'localadmin92@example.com')

convict_pontoise = create_convict(organizations: [org_tj_pontoise, org_spip_95], city: pontoise)
convict_versailles = create_convict(organizations: [org_tj_versailles, org_spip_78], city: versailles)
convict_chartres = create_convict(organizations: [org_tj_chartres, org_spip_28], city: chartres)
convict_nanterre = create_convict(organizations: [org_tj_nanterre, org_spip_92], city: nanterre)

Appointment.create!(slot: slot_tj_pontoise, convict: convict_pontoise, inviter_user_id: bex_pontoise.id).book(send_notification: false)
Appointment.create!(slot: slot_tj_versailles, convict: convict_versailles, inviter_user_id: bex_versailles.id).book(send_notification: false)
Appointment.create!(slot: slot_tj_chartres, convict: convict_chartres, inviter_user_id: bex_chartres.id).book(send_notification: false)
Appointment.create!(slot: slot_tj_nanterre, convict: convict_nanterre, inviter_user_id: bex_nanterre.id).book(send_notification: false)

Appointment.create!(slot: slot_spip_95, convict: convict_pontoise, inviter_user_id: cpip_95.id).book(send_notification: false)
Appointment.create!(slot: slot_spip_78, convict: convict_versailles, inviter_user_id: cpip_78.id).book(send_notification: false)
Appointment.create!(slot: slot_spip_28, convict: convict_chartres, inviter_user_id: cpip_28.id).book(send_notification: false)
Appointment.create!(slot: slot_spip_92, convict: convict_nanterre, inviter_user_id: cpip_92.id).book(send_notification: false)

SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_92, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_nanterre, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)

SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_95, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_pontoise, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)

SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_78, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_versailles, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)

SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_28, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_chartres, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)
SlotFactory.perform