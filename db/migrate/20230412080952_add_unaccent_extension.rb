class AddUnaccentExtension < ActiveRecord::Migration[6.1]
  def up
    execute "create extension unaccent"
  end

  def down
    execute "drop extension unaccent"
  end
end
