class AddAppointmentAddedFieldsToOrganization < ActiveRecord::Migration[6.1]
  def change
    add_column :organizations, :appointment_added_fields, :json, null: false, default: '{}'
  end
end
