class CreateJoinTableAppointmentTypeExtraField < ActiveRecord::Migration[6.1]
  def change
    create_join_table :appointment_types, :extra_fields do |t|
      # t.index [:appointment_type_id, :extra_field_id]
      # t.index [:extra_field_id, :appointment_type_id]
    end
  end
end
