require 'faker'

org_tj_pontoise = Organization.find_or_create_by!(name: 'TJ Pontoise', organization_type: 'tj', use_inter_ressort: true)
org_tj_versailles = Organization.find_or_create_by!(name: 'TJ Versailles', organization_type: 'tj', use_inter_ressort: true)
org_tj_nanterre = Organization.find_or_create_by!(name: 'TJ Nanterre', organization_type: 'tj', use_inter_ressort: true)
org_tj_chartres = Organization.find_or_create_by!(name: 'TJ Chartres', organization_type: 'tj', use_inter_ressort: true)

org_spip_95 = Organization.find_or_create_by!(name: 'SPIP 95', organization_type: 'spip') do |org|
  org.tjs = [org_tj_pontoise]
end

org_spip_92 = Organization.find_or_create_by!(name: 'SPIP 92', organization_type: 'spip') do |org|
  org.tjs = [org_tj_nanterre]
end

org_spip_28 = Organization.find_or_create_by!(name: 'SPIP 28', organization_type: 'spip') do |org|
  org.tjs = [org_tj_chartres]
end

org_spip_78 = Organization.find_or_create_by!(name: 'SPIP 78', organization_type: 'spip') do |org|
  org.tjs = [org_tj_versailles]
end

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


place_tj_pontoise = Place.find_or_create_by!(organization: org_tj_pontoise, name: "TJ Pontoise", adress: "3 Rue Victor Hugo, 95300 Pontoise", phone: '+33606060606')
place_tj_versailles = Place.find_or_create_by!(organization: org_tj_versailles, name: "TJ Versailles", adress: "5 Rue Carnot, 78000 Versailles", phone: '+33606060606')
place_tj_chartres = Place.find_or_create_by!(organization: org_tj_chartres, name: "TJ Chartres", adress: "1 Rue Saint-Jacques, 28000 Chartres", phone: '+33606060606')
place_tj_nanterre = Place.find_or_create_by!(organization: org_tj_nanterre, name: "TJ Nanterre", adress: "179-191 Avenue Joliot Curie, 92000 Nanterre", phone: '+33606060606')

place_spip_92 = Place.find_or_create_by!(organization: org_spip_92, name: "SPIP 92", adress: "179-191 Avenue Joliot Curie, 92000 Nanterre", phone: '+33606060606')
place_spip_28 = Place.find_or_create_by!(organization: org_spip_28, name: "SPIP 28", adress: "1 Rue Saint-Jacques, 28000 Chartres", phone: '+33606060606')
place_spip_95 = Place.find_or_create_by!(organization: org_spip_95, name: "SPIP 95", adress: "3 Rue Victor Hugo, 95300 Pontoise", phone: '+33606060606')
place_spip_78 = Place.find_or_create_by!(organization: org_spip_78, name: "SPIP 78", adress: "5 Rue Carnot, 78000 Versailles", phone: '+33606060606')

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

slot_tj_pontoise = Slot.create(agenda: agenda_tj_pontoise, starting_time: Time.zone.now, date: Date.tomorrow.next_occurring(:monday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_sap)
slot_tj_versailles = Slot.create(agenda: agenda_tj_versailles, starting_time: Time.zone.now, date: Date.tomorrow.next_occurring(:monday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_sap)
slot_tj_nanterre = Slot.create(agenda: agenda_tj_nanterre, starting_time: Time.zone.now, date: Date.tomorrow.next_occurring(:monday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_sap)
slot_tj_chartres = Slot.create(agenda: agenda_tj_chartres, starting_time: Time.zone.now, date: Date.tomorrow.next_occurring(:monday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_sap)

slot_spip_92 = Slot.create(agenda: agenda_spip_92, starting_time: Time.zone.now, date: Date.tomorrow.next_occurring(:tuesday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_spip)
slot_spip_95 =Slot.create(agenda: agenda_spip_95, starting_time: Time.zone.now, date: Date.tomorrow.next_occurring(:tuesday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_spip)
slot_spip_28 =Slot.create(agenda: agenda_spip_28, starting_time: Time.zone.now, date: Date.tomorrow.next_occurring(:tuesday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_spip)
slot_spip_78 = Slot.create(agenda: agenda_spip_78, starting_time: Time.zone.now, date: Date.tomorrow.next_occurring(:tuesday), duration: 15, capacity: 5, appointment_type: apt_type_sortie_audience_spip)

user_pontoise = User.find_or_create_by!(
  organization: org_tj_pontoise, email: 'bextjpontoise@example.com', role: :bex
) do |user|
  user.password = ENV["DUMMY_PASSWORD"]
  user.password_confirmation = ENV["DUMMY_PASSWORD"]
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

user_versaille = User.find_or_create_by!(
  organization: org_tj_versailles, email: 'bextjversailles@example.com', role: :bex
) do |user|
  user.password = ENV["DUMMY_PASSWORD"]
  user.password_confirmation = ENV["DUMMY_PASSWORD"]
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

user_chartres = User.find_or_create_by!(
  organization: org_tj_chartres, email: 'bextjchartres@example.com', role: :bex
) do |user|
  user.password = ENV["DUMMY_PASSWORD"]
  user.password_confirmation = ENV["DUMMY_PASSWORD"]
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

user_nanterre = User.find_or_create_by!(
  organization: org_tj_nanterre, email: 'bextjnanterre@example.com', role: :bex
) do |user|
  user.password = ENV["DUMMY_PASSWORD"]
  user.password_confirmation = ENV["DUMMY_PASSWORD"]
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end


Faker::Config.locale = 'fr'
convict_pontoise = Convict.create!(no_phone: true, city: pontoise, appi_uuid: Faker::Number.unique.number(digits: 12), date_of_birth: Faker::Date.in_date_period(year: 1989), organizations: [org_tj_pontoise, org_spip_95]) do |convict|
  convict.first_name = Faker::Name.first_name
  convict.last_name = Faker::Name.last_name
end

convict_versailles = Convict.create!(no_phone: true, city: versailles, appi_uuid: Faker::Number.unique.number(digits: 12), date_of_birth: Faker::Date.in_date_period(year: 1989), organizations: [org_tj_versailles, org_spip_78]) do |convict|
  convict.first_name = Faker::Name.first_name
  convict.last_name = Faker::Name.last_name
end

convict_chartres = Convict.create!(no_phone: true, city: chartres, appi_uuid: Faker::Number.unique.number(digits: 12), date_of_birth: Faker::Date.in_date_period(year: 1989), organizations: [org_tj_chartres, org_spip_28]) do |convict|
  convict.first_name = Faker::Name.first_name
  convict.last_name = Faker::Name.last_name
end

convict_nanterre = Convict.create!(no_phone: true, city: nanterre, appi_uuid: Faker::Number.unique.number(digits: 12), date_of_birth: Faker::Date.in_date_period(year: 1989), organizations: [org_tj_nanterre, org_spip_92]) do |convict|
  convict.first_name = Faker::Name.first_name
  convict.last_name = Faker::Name.last_name
end

Appointment.create!(slot: slot_tj_pontoise, convict: convict_pontoise, inviter_user_id: user_pontoise.id).book(send_notification: false)
Appointment.create!(slot: slot_tj_versailles, convict: convict_versailles, inviter_user_id: user_versaille.id).book(send_notification: false)
Appointment.create!(slot: slot_tj_chartres, convict: convict_chartres, inviter_user_id: user_chartres.id).book(send_notification: false)
Appointment.create!(slot: slot_tj_nanterre, convict: convict_nanterre, inviter_user_id: user_nanterre.id).book(send_notification: false)

