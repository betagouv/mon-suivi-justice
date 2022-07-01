class AddReferenceToOrganizationOnNotificationType < ActiveRecord::Migration[6.1]
  def change
    add_reference :notification_types, :organization, foreign_key: true
  end
end
