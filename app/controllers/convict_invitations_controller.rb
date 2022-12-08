class ConvictInvitationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @convict = Convict.find(params[:convict_id])
    authorize @convict, policy_class: ConvictInvitationPolicy
    params = { phone: @convict.phone, msj_id: @convict.id, first_name: @convict.first_name,
               last_name: @convict.last_name }

    ConvictInvitationNotification.with(invitation_params: params, status: :pending,
                                       type: :info).deliver_later(current_user)
    InviteConvictJob.perform_later(@convict.id, current_user)
  end
end
