class ArchiveUnactiveConvictsJob < ApplicationJob
  def perform
    ArchiveUnactiveConvicts.call
  end
end
