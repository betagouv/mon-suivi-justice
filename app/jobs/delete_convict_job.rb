class DeleteConvictJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :default

  def perform(convict_id)
    MonSuiviJusticePublicApi::Convict.delete(convict_id)
  end
end
