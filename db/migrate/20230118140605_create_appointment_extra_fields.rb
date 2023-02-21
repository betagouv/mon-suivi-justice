class CreateAppointmentExtraFields < ActiveRecord::Migration[6.1]
  def change
    create_table :appointment_extra_fields do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :extra_field, null: false, foreign_key: true
      t.string :value, null: false

      t.timestamps
    end
  end
end
