class AddPreparationLinkToPlace < ActiveRecord::Migration[6.1]
  def change
    add_column :places, :preparation_link, :string, null: false, default: "https://mon-suivi-justice.beta.gouv.fr/"
  end
end
