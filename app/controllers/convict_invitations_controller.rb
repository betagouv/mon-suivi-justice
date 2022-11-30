class ConvictInvitationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @convict = Convict.find(params[:convict_id])
    authorize @convict, policy_class: ConvictInvitationPolicy
    params = { phone: @convict.phone, msj_id: @convict.id, first_name: @convict.first_name,
               last_name: @convict.last_name }
    InviteConvictJob.perform_later(@convict.id, current_user)
    ConvictInvitationNotification.with(invitation_params: params, status: :pending).deliver(current_user)
  end
end
