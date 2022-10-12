class InviteConvictJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :default

  def perform(convict_id)
    @convict = Convict.find(convict_id)
    return unless @convict.phone.present?

    params = { phone: @convict.phone, msj_id: @convict.id, first_name: @convict.first_name,
               last_name: @convict.last_name }

    MonSuiviJusticePublicApi::Invitation.create(params)
    @convict.increment!(:invitation_to_convict_interface_count)
    @convict.update(last_invite_to_convict_interface: Time.zone.now)
  end
end
