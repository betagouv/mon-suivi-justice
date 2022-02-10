class AddIndexUniquenessValidateSlotType < ActiveRecord::Migration[6.1]
  def up
    SlotType.all
            .group_by do |model|
              [model.starting_time,model.agenda_id,model.appointment_type_id,model.week_day]
            end.select{ |k, v| v.count > 1 }
            .map{ |k,v| v.last }
            .each(&:destroy)

    add_index :slot_types, %i[starting_time agenda_id appointment_type_id week_day], unique: true, name: :index_slot_types_on_starting_time_combination
  end

  def down
    remove_index :slot_types, name: :index_slot_types_on_starting_time_combination
  end
end
