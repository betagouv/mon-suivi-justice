class SlotCreationJob < ApplicationJob
  def perform(oneshot: false)
    SlotFactory.perform
    SlotCreationJob.set(wait: 1.week).perform_later unless oneshot
  end
end
