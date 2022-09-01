class AddTimeZoneToOrganizations < ActiveRecord::Migration[6.1]
  def change
    add_column :organizations, :time_zone, :string, default: 'Paris', null: false
  end
end
