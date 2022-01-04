require 'rufus-scheduler'

#
# Rufus scheduler wont be initialized in console, test/dev env and rake task
#
unless defined?(Rails::Console) || Rails.env.test? || Rails.env.development? || File.split($PROGRAM_NAME).last == 'rake'
  #
  # CRON syntax reminder : "man 5 crontab" in your terminal
  # field          allowed values
  # -----          --------------
  # minute         0-59
  # hour           0-23
  # day of month   1-31
  # month          1-12
  # day of week    0-7 (0 or 7 is Sun)
  #
  Rufus::Scheduler.singleton.cron '5 0 * * *', overlap: false do
    # Every day at 00:05, create all Slot from SlotTypes
    SlotCreationJob.perform_later
  end

  Rufus::Scheduler.singleton.cron '10 0 * * *', overlap: false do
    # Every day at 00:10, delete convicts archived 6 months ago
    ArchivedConvictsDestroy.perform_later
  end
end
