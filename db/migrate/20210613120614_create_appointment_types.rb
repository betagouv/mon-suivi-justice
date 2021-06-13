class CreateAppointmentTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :appointment_types do |t|
      t.string :name
      
      t.timestamps
    end
  end
end
