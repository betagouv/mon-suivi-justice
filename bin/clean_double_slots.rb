# rails r bin/clean_double_slots.rb

require 'ruby-progressbar'

progress = ProgressBar.create(total: Slot.count)

problems = []

def delete_slots(doubles, nb_to_delete)
  deleted = 0
  doubles.each do |slot|
    next if deleted == nb_to_delete
    if slot.appointments.empty?
      slot.delete
      deleted += 1
    end
  end
end

Slot.future.each do |slot|
  progress.increment

  result = Slot.where(date: slot.date, slot_type: slot.slot_type, starting_time: slot.starting_time)

  case result.length
  when 1
    next
  else
    delete_slots(result, result.length - 1)
  end

  check_result = Slot.where(date: slot.date, slot_type: slot.slot_type, starting_time: slot.starting_time)

  case check_result.length
  when 1
    next
  else
    problems << check_result.pluck(:id)
  end
end

p "non-deleted doubles :"
p problems.uniq
