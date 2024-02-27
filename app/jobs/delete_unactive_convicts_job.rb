class DeleteUnactiveConvictsJob < ApplicationJob
  def perform
    DeleteUnactiveConvictsService.call
  end
end
