json.id appointment.id
json.date appointment.date
json.starting_time appointment.starting_time.to_s(:time)
json.duration appointment.duration
json.state appointment.human_state_name
json.organization_name appointment.organization_name
json.origin_department I18n.translate("activerecord.attributes.appointment.origin_departments.#{appointment.origin_department}") # rubocop:disable Metrics/LineLength
json.appointment_type_name appointment.appointment_type_name
json.place_name appointment.place_name
json.place_adress appointment.place_adress
json.place_phone appointment.place_phone
json.place_email appointment.place_contact_email
json.place_contact_method appointment.place_main_contact_method
json.agenda_name appointment.agenda_name
