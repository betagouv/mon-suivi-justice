class InviteConvictJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :default

  def perform(convict_id)
    @convict = Convict.find(convict_id)
    MonSuiviJusticePublicApi::Invitation.create(phone: @convict.phone, msj_id: @convict.id)
  end
end
