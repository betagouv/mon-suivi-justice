class CreateAgendas < ActiveRecord::Migration[6.1]
  def change
    create_table :agendas do |t|
      t.string :name
      
      t.references :place, index: true, foreign_key: true
      t.timestamps
    end
  end
end
