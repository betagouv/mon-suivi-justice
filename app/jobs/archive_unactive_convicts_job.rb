class ArchiveUnactiveConvictsJob < ApplicationJob
  def perform
    convicts_to_archive_service = Cleanup::ArchiveUnactiveConvicts.new
    puts convicts_to_archive_service.convicts.count
    convicts_to_archive_service.call
  end
end
