class SlotCreationJob < ApplicationJob
  def perform
    SlotFactory.perform
  end
end
