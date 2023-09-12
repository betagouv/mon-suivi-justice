class UserAlertsController < ApplicationController
  def mark_as_read
    @alert = UserAlert.find(params[:id])

    authorize @alert, :mark_as_read?

    if @alert.mark_as_read!
      render json: { success: true }
    else
      render json: { success: false, error: 'Impossible de marquer comme lu' }, status: 422
    end
  rescue Pundit::NotAuthorizedError
    render json: { success: false, error: "Vous n'êtes pas autorisé à marquer cette alerte comme lue" }, status: 403
  end
end
