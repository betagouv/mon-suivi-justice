class ArchivedConvictsDestroyJob < ApplicationJob
  def perform
    convicts = Convict.where('discarded_at < ?', 6.months.ago)
    convicts.find_each(&:destroy!)
  end
end
