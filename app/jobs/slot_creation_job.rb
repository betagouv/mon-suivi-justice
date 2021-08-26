class SlotCreationJob < ApplicationJob
  sidekiq_options retry: 5

  queue_as :default

  def perform
    SlotFactory.new
    SlotCreationJob.set(wait: 1.minute).perform_later
  end
end
