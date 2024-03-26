class InviteConvictJob < ApplicationJob
  sidekiq_options retry: 5

  queue_as :default
  def perform(convict_id, user_id = nil)
    @convict = Convict.find(convict_id)
    return unless @convict.phone.present?

    params = { phone: @convict.phone, msj_id: @convict.id, first_name: @convict.first_name,
               last_name: @convict.last_name }

    MonSuiviJusticePublicApi::Invitation.create(params)
    @convict.increment!(:invitation_to_convict_interface_count)
    @convict.update(last_invite_to_convict_interface: Time.zone.now)
    return unless user_id.present?

    sleep 3 # without sleep, the broadcast can happen before the show page is loaded
    user = User.find(user_id)
    Turbo::StreamsChannel.broadcast_replace_to [user, @convict, 'convict_invitation_card'],
                                               partial: 'convicts/invitation_card',
                                               locals: { convict: @convict, user: },
                                               target: 'convict_invitation_card'
  end
end
