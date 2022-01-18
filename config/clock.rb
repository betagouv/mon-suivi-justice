require 'clockwork'
require 'active_support/time'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  every(1.day, 'slot_creation.job', at: '00:00') { SlotCreationJob.perform_later }
  every(1.day, 'archived_convict_deletion.job', at: '01:00') { ArchivedConvictsDestroyJob.perform_later }
end
