class ArchiveUnactiveConvictsJob < ApplicationJob
  # TODO: Remove this job in August 2024 in favor of ArchivedConvictsDestroyJob
  # (which will do the same as DeleteUnactiveConvictsJob will be in place for more than 6 months)
  def perform
    convicts_to_archive_service = Cleanup::ArchiveUnactiveConvicts.new
    puts convicts_to_archive_service.convicts.count
    convicts_to_archive_service.call
  end
end
