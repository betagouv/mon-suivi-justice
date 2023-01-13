class AddOrganizationSpecificDataToAppointment < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :organization_specific_data, :json, null: false, default: {}
  end
end
