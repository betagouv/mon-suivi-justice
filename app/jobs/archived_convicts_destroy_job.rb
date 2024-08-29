class ArchivedConvictsDestroyJob < ApplicationJob
  def perform
    convicts = Convict.where('discarded_at < ?', Convict::ARCHIVE_DURATION.ago)
    convicts.find_each(&:destroy!)
  end
end
