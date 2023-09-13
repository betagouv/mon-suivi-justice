class UserAlertsController < ApplicationController
  before_action :find_alert, only: %i[mark_as_read]

  def mark_as_read
    if @alert.mark_as_read!
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove("alert_#{@alert.id}")
        end
      end
    else
      stream_error_messages(object)
    end
  end

  private

  def find_alert
    @alert = UserAlert.find(params[:id])
    authorize @alert, :mark_as_read?
  end
end
