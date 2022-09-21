class TrackingCleaningJob < ApplicationJob
  def perform
    Ahoy::Visit.where('started_at < ?', 1.year.ago).find_in_batches do |visits|
      visit_ids = visits.map(&:id)
      Ahoy::Event.where(visit_id: visit_ids).delete_all
      Ahoy::Visit.where(id: visit_ids).delete_all
    end
  end
end
