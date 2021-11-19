require 'rufus-scheduler'

#
# Rufus scheduler wont be initialized in console, test/dev env and rake task
#
unless defined?(Rails::Console) || Rails.env.test? || Rails.env.development? || File.split($PROGRAM_NAME).last == 'rake'
  Rufus::Scheduler.singleton.every '1m' do
    # Je fais tourner ca sur staging 10min histoire de voir si ca marche, apres je remplace par les vrai jobs :p
    Rails.logger.info '===============RUFUS_SCHEDULER_TEST_INIT==============='
  end
end
