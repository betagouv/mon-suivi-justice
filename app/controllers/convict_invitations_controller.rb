class ConvictInvitationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @convict = Convict.find(params[:convict_id])
    authorize @convict, policy_class: ConvictInvitationPolicy
    params = { phone: @convict.phone, msj_id: @convict.id, first_name: @convict.first_name,
               last_name: @convict.last_name }

    InviteConvictJob.perform_later(@convict.id, current_user)

    redirect_to convict_path(@convict), notice: t('.invitation_pending')
  end
end
