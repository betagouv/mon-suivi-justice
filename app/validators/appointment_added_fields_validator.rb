class AppointmentAddedFieldsValidator < ActiveModel::Validator
  def validate(record)
    if record.appointment_added_fields.keys().size > 3
      record.errors.add :appointment_added_fields, "can't have more than 3 extra fields"
    end
  end
end