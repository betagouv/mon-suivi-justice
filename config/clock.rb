require 'clockwork'
require 'active_support/time'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  every(1.day, 'slot_creation.job', at: '00:00') { SlotCreationJob.perform_later }
  every(1.day, 'archived_convict_deletion.job', at: '01:00') { ArchivedConvictsDestroyJob.perform_later }
  every(1.day, 'tracking_cleaning.job', at: '02:00') { TrackingCleaningJob.perform_later }

  # Populate dedicted pgsql tables for Metabse. Do this one only on production env
  if ENV['APP'] == 'mon-suivi-justice-prod'
    every(1.day, 'execute_stored_procedures.job', at: '03:00') { ExecuteStoredProceduresJob.perform_later }
  end
end
