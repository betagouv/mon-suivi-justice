require 'faker'


org_spip_37_tours = Organization.find_or_create_by!(name: 'SPIP 37 - Tours', organization_type: 'spip')
org_tj_tours = Organization.find_or_create_by!(name: 'TJ Tours', organization_type: 'tj') do |org|
  org.spips = [org_spip_37_tours]
end

place_spip_37_tours = Place.find_or_create_by!(organization_id: org_spip_37_tours.id, name: "SPIP 37 - Tours", adress: "2 rue Albert Dennery BP 2603, 37000 Tours", phone: '+33606060606')
place_tj_tours = Place.find_or_create_by!(organization_id: org_tj_tours.id, name: "TJ Tours", adress: "2 PLACE JEAN-JAURES 37928 Tours", phone: '+33606060606')

apt_type_sortie_audience_sap = AppointmentType.find_or_create_by!(name: "Sortie d'audience SAP")
apt_type_sortie_audience_spip = AppointmentType.find_or_create_by!(name: "Sortie d'audience SPIP")

PlaceAppointmentType.find_or_create_by!(place: place_spip_37_tours, appointment_type: apt_type_sortie_audience_spip)
PlaceAppointmentType.find_or_create_by!(place: place_tj_tours, appointment_type: apt_type_sortie_audience_sap)

Agenda.find_or_create_by!(place: place_spip_37_tours, name: "Agenda SPIP Tours")
agenda_tj = Agenda.find_or_create_by!(place: place_tj_tours, name: "Agenda TJ Tours")

Slot.create!(agenda: agenda_tj, starting_time: Time.zone.now, date: Date.tomorrow.next_occurring(:monday), duration: 15, capacity: 1, appointment_type: apt_type_sortie_audience_sap)

User.find_or_create_by!(
  organization: org_spip_37_tours, email: 'cpip37tours@example.com', role: :cpip
) do |user|
  user.password = '1mot2passeSecurise!'
  user.password_confirmation = '1mot2passeSecurise!'
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

User.find_or_create_by!(
  organization: org_spip_37_tours, email: 'localadmin37tours@example.com', role: :local_admin
) do |user|
  user.password = '1mot2passeSecurise!'
  user.password_confirmation = '1mot2passeSecurise!'
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

User.find_or_create_by!(
  organization: org_tj_tours, email: 'bextours@example.com', role: :bex
  
) do |user|
  user.password = '1mot2passeSecurise!'
  user.password_confirmation = '1mot2passeSecurise!'
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

User.find_or_create_by!(
  organization: org_tj_tours, email: 'localadmintjtours@example.com', role: :local_admin
) do |user|
  user.password = '1mot2passeSecurise!'
  user.password_confirmation = '1mot2passeSecurise!'
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
end

ExtraField.find_or_create_by!(name: 'Transmission PAP à EP', data_type: :date, scope: :appointment_update, organization: org_tj_tours) do |extra_field|
  extra_field.appointment_types = [apt_type_sortie_audience_sap, apt_type_sortie_audience_spip]
end
ExtraField.find_or_create_by!(name: 'Transmission EP à SPIP', data_type: :date, scope: :appointment_update, organization: org_tj_tours) do |extra_field|
  extra_field.appointment_types = [apt_type_sortie_audience_spip]
end
ExtraField.find_or_create_by!(name: 'Transmission EP à JAP', data_type: :date, scope: :appointment_update, organization: org_tj_tours) do |extra_field|
  extra_field.appointment_types = [apt_type_sortie_audience_sap]
end

ExtraField.find_or_create_by!(name: 'Jurisdiction de condamnation', data_type: :text, scope: :appointment_create, organization: org_tj_tours) do |extra_field|
  extra_field.appointment_types = [apt_type_sortie_audience_sap, apt_type_sortie_audience_spip]
end