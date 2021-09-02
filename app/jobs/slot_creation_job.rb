class SlotCreationJob < ApplicationJob
  def perform
    SlotFactory.perform
    SlotCreationJob.set(wait: 1.week).perform_later
  end
end
