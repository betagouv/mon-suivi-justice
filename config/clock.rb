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
  every(1.day, 'archive_unactive_convicts.job', at: '01:00') { ArchiveUnactiveConvictsJob.perform_later }
  every(1.day, 'tracking_cleaning.job', at: '02:00') { TrackingCleaningJob.perform_later }
  every(1.day, 'transfert_places.job', at: '03:00') { TransfertPlacesJob.perform_later }

  # Populate dedicted pgsql tables for Metabse. Do this one only on production env
  if ENV['APP'] == 'mon-suivi-justice-prod'
    every(1.day, 'execute_stored_procedures.job', at: '04:00') { ExecuteStoredProceduresJob.perform_later }
    every(1.day, 'manage_notification_problems.job', at: '04:00') { ManageNotificationProblems.perform_later }
  end

  every(1.day, 'delete_place_transfert', at: '05:00') { DeletePlaceTransfertJob.perform_later }
  every(1.day, 'handle_stalled_divestments', at: '06:00') { HandleStalledDivestmentsJob.perform_later }
  every(1.hour, 'sms_schedule.job') { SmsScheduleJob.perform_later }
end
