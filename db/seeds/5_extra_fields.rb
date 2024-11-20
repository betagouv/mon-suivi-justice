require_relative '../seed_utils.rb'

org_tj_tours = create_tj(name: 'TJ Tours')
org_spip_37_tours = create_spip(name: 'SPIP 37 - Tours', tjs: org_tj_tours)

place_spip_37_tours = find_or_create_without_validation_by(Place,organization_id: org_spip_37_tours.id, name: "SPIP 37 - Tours", adress: "2 rue Albert Dennery BP 2603, 37000 Tours", phone: '+33606060606')
place_tj_tours = find_or_create_without_validation_by(Place,organization_id: org_tj_tours.id, name: "TJ Tours", adress: "2 PLACE JEAN-JAURES 37928 Tours", phone: '+33606060606')

apt_type_sortie_audience_sap = AppointmentType.find_or_create_by!(name: "Sortie d'audience SAP")
apt_type_sortie_audience_spip = AppointmentType.find_or_create_by!(name: "Sortie d'audience SPIP")

PlaceAppointmentType.find_or_create_by!(place: place_spip_37_tours, appointment_type: apt_type_sortie_audience_spip)
PlaceAppointmentType.find_or_create_by!(place: place_tj_tours, appointment_type: apt_type_sortie_audience_sap)

Agenda.find_or_create_by!(place: place_spip_37_tours, name: "Agenda SPIP Tours")
agenda_tj = Agenda.find_or_create_by!(place: place_tj_tours, name: "Agenda TJ Tours")

Slot.create!(agenda: agenda_tj, starting_time: Time.zone.now, date: next_valid_day(day: :monday), duration: 15, capacity: 1, appointment_type: apt_type_sortie_audience_sap)

create_user(
  organization: org_spip_37_tours, email: 'cpip37tours@example.com', role: :cpip
)

create_user(
  organization: org_spip_37_tours, email: 'localadmin37tours@example.com', role: :local_admin
)

create_user(
  organization: org_tj_tours, email: 'bextours@example.com', role: :bex
)

create_user(
  organization: org_tj_tours, email: 'localadmintjtours@example.com', role: :local_admin
)
create_user(organization: org_tj_tours, email: 'greffsap_tj_tours@example.com', role: :greff_sap)

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