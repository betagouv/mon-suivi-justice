class DeleteUnactiveConvictsJob < ApplicationJob
  def perform
    convicts_to_delete_service = Cleanup::DeleteUnactiveConvicts.new
    puts convicts_to_delete_service.convicts.count
    convicts_to_delete_service.call
  end
end
