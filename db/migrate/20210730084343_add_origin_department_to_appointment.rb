class AddOriginDepartmentToAppointment < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :origin_department, :integer, default: 0
  end
end
