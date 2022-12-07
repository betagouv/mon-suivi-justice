class InviteConvictJob < ApplicationJob
  def perform(convict_id, current_user)
    @convict = Convict.find(convict_id)
    return unless @convict.phone.present?

    params = { phone: @convict.phone, msj_id: @convict.id, first_name: @convict.first_name,
               last_name: @convict.last_name }

    # MonSuiviJusticePublicApi::Invitation.create(params)
    # @convict.increment!(:invitation_to_convict_interface_count)
    # @convict.update(last_invite_to_convict_interface: Time.zone.now)
    return unless current_user.present?
    sleep(1.5)
    ConvictInvitationNotification.with(invitation_params: params,
                                       status: :sent, type: :success).deliver(current_user)
  end
end
