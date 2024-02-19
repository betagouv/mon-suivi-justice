class ConvictInvitationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @convict = Convict.find(params[:convict_id])
    authorize @convict, policy_class: ConvictInvitationPolicy

    InviteConvictJob.perform_later(@convict.id)

    redirect_to convict_path(@convict), notice: t('.invitation_pending')
  end
end
