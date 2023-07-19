require 'faker'

org_tj_bordeaux = Organization.find_or_create_by!(name: 'TJ de Bordeaux', organization_type: 'tj')
org_spip_33_bordeaux = Organization.find_or_create_by!(name: 'SPIP 33 - Bordeaux', organization_type: 'spip') do |org|
  org.tjs = [org_tj_bordeaux]
end

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

User.find_or_create_by!(
  organization: org_spip_33_bordeaux, email: 'cpip33bdx@example.com', role: :cpip
) do |user|
  user.password = ENV["DUMMY_PASSWORD"]
  user.password_confirmation = ENV["DUMMY_PASSWORD"]
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

User.find_or_create_by!(
  organization: org_spip_33_bordeaux, email: 'localadmin33bdx@example.com', role: :local_admin
) do |user|
  user.password = ENV["DUMMY_PASSWORD"]
  user.password_confirmation = ENV["DUMMY_PASSWORD"]
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

User.find_or_create_by!(
  organization: org_tj_bordeaux, email: 'bextjbdx@example.com', role: :bex
) do |user|
  user.password = ENV["DUMMY_PASSWORD"]
  user.password_confirmation = ENV["DUMMY_PASSWORD"]
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

User.find_or_create_by!(
  organization: org_tj_bordeaux, email: 'localadmintjbdx@example.com', role: :local_admin
) do |user|
  user.password = ENV["DUMMY_PASSWORD"]
  user.password_confirmation = ENV["DUMMY_PASSWORD"]
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

SlotType.create(appointment_type: apt_type_sortie_audience_spip, agenda: agenda_spip_bordeaux, week_day: :monday, starting_time: Time.new(2021, 6, 21, 11, 00, 0), duration: 60, capacity: 3)
SlotType.create(appointment_type: apt_type_sap_ddse, agenda: agenda_spip_bordeaux, week_day: :thursday, starting_time: Time.new(2021, 6, 21, 15, 00, 0), duration: 60, capacity: 5)
SlotType.create(appointment_type: apt_type_sortie_audience_sap, agenda: agenda_tj_bordeaux, week_day: :wednesday, starting_time: Time.new(2021, 6, 21, 10, 00, 0), duration: 60, capacity: 3)

SlotFactory.perform

Faker::Config.locale = 'fr'
Convict.create!(phone: Faker::PhoneNumber.unique.cell_phone, appi_uuid: Faker::Number.unique.number(digits: 12), date_of_birth: Faker::Date.in_date_period(year: 1989), organizations: [org_spip_33_bordeaux, org_tj_bordeaux]) do |convict|
  convict.first_name = Faker::Name.first_name
  convict.last_name = Faker::Name.last_name
end
Convict.create!(phone: Faker::PhoneNumber.unique.cell_phone, appi_uuid: Faker::Number.unique.number(digits: 12), date_of_birth: Faker::Date.in_date_period(year: 1989), organizations: [org_spip_33_bordeaux, org_tj_bordeaux]) do |convict|
  convict.first_name = Faker::Name.first_name
  convict.last_name = Faker::Name.last_name
end
Convict.create!(phone: Faker::PhoneNumber.unique.cell_phone, appi_uuid: Faker::Number.unique.number(digits: 12), date_of_birth: Faker::Date.in_date_period(year: 1989), organizations: [org_spip_33_bordeaux, org_tj_bordeaux]) do |convict|
  convict.first_name = Faker::Name.first_name
  convict.last_name = Faker::Name.last_name
end
Convict.create!(phone: Faker::PhoneNumber.unique.cell_phone, appi_uuid: Faker::Number.unique.number(digits: 12), date_of_birth: Faker::Date.in_date_period(year: 1989), organizations: [org_spip_33_bordeaux, org_tj_bordeaux]) do |convict|
  convict.first_name = Faker::Name.first_name
  convict.last_name = Faker::Name.last_name
end