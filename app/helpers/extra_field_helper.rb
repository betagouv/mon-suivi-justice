module ExtraFieldHelper
  def display_extra_field(extra_field, appointment)
    return unless appointment.present? && extra_field.present?

    appointment_extra_field = extra_field.appointment_extra_fields_for_appointment(appointment.id)
    return unless appointment_extra_field.present?

    if appointment_extra_field.value.present? && extra_field.data_type == 'date'
      return appointment_extra_field.value.to_date
    end

    appointment_extra_field.value
  end
end
