class ChangeTjsAndSpipsToSrjTjsAndSpips < ActiveRecord::Migration[6.1]
  def change
    rename_table :tjs, :srj_tjs
    rename_table :spips, :srj_spips
  end
end
