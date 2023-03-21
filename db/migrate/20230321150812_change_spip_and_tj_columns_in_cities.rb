class ChangeSpipAndTjColumnsInCities < ActiveRecord::Migration[6.1]
  def change
    change_table :cities do |t|
      t.rename :spip_id, :srj_spip_id
      t.rename :tj_id, :srj_tj_id
    end
  end
end
