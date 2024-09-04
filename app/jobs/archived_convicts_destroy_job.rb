class ArchivedConvictsDestroyJob < ApplicationJob
  def perform
    Convict.destroy_by('discarded_at < ?', Convict::ARCHIVE_DURATION.ago)
  end
end
