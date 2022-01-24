class AddMailToPlaces < ActiveRecord::Migration[6.1]
  def change
    add_column :places, :contact_email, :string
    add_column :places, :main_contact, :integer, default: 0, null: false

    Place.update_all(main_contact: 0)
  end
end
