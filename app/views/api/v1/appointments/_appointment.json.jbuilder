json.id appointment.id
json.datetime appointment.datetime
json.duration appointment.duration
json.state appointment.human_state_name
json.origin_department I18n.translate("activerecord.attributes.appointment.origin_departments.#{appointment.origin_department}") if appointment.origin_department.present? # rubocop:disable Metrics/LineLength
json.place do
  json.partial! 'api/v1/places/place', place: appointment.place
end
json.display_address appointment.appointment_type_share_address_to_convict
json.organization_name appointment.organization_name
json.agenda_name appointment.agenda_name
json.appointment_type_name appointment.appointment_type_name
