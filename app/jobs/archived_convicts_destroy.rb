class ArchivedConvictsDestroy < ApplicationJob
  def perform
    convicts = Convict.deleted_before_time 6.months.ago
    convicts.find_each(&:destroy_fully!)
  end
end
