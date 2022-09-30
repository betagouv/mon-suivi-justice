class AddDiscardedAtToAgendas < ActiveRecord::Migration[6.1]
  def change
    add_column :agendas, :discarded_at, :datetime
    add_index :agendas, :discarded_at
  end
end
