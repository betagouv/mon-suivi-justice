class AddShareAddressToConvictToAppointmentType < ActiveRecord::Migration[6.1]
  def change
    add_column :appointment_types, :share_address_to_convict, :boolean, default: true, null: false
  end
end
