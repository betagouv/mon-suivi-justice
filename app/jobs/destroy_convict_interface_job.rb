class DestroyConvictInterfaceJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :default

  def perform(convict_id)
    MonSuiviJusticePublicApi::Convict.destroy(convict_id)
  end
end
