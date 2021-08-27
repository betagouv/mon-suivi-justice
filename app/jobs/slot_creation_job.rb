class SlotCreationJob < ApplicationJob
  def perform
    SlotFactory.new
    SlotCreationJob.set(wait: 1.week).perform_later
  end
end
