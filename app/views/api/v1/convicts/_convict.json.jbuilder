json.id convict.id
json.first_name convict.first_name
json.last_name convict.last_name
json.phone convict.phone
json.appointments convict.appointments do |appointment|
  json.partial! "api/v1/appointments/appointment", appointment: appointment
end
