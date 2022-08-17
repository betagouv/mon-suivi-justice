class RemoveDefaultFromAppointmentOriginDepartment < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:appointments, :origin_department, nil)
  end
end
