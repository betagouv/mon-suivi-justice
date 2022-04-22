class InviteConvictJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :default

  def perform(convict_id)
    @convict = Convict.find(convict_id)
    return unless @convict.phone.present?

    MonSuiviJusticePublicApi::Invitation.create(phone: @convict.phone, msj_id: @convict.id)
    @convict.increment!(:invitation_to_convict_interface_count)
  end
end
