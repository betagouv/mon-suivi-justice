class DeleteConvictJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :default

  def perform(convict_id)
    convict = Convict.find(convict_id)
    MonSuiviJusticePublicApi::Convict.delete(convict)
  end
end
