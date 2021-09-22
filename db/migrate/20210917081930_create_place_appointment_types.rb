class CreatePlaceAppointmentTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :place_appointment_types do |t|
      t.belongs_to :place
      t.belongs_to :appointment_type

      t.timestamps
    end
  end
end
