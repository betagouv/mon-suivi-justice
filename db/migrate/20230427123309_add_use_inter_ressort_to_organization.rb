class AddUseInterRessortToOrganization < ActiveRecord::Migration[6.1]
  def change
    add_column :organizations, :use_inter_ressort, :boolean, default: false
  end
end
