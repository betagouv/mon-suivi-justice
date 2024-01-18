class UserUserAlertsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user_user_alert, only: %i[mark_as_read]

  def mark_as_read
    authorize @user_user_alert

    if @user_user_alert.update(read_at: Time.current)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove("user_user_alert_#{params[:id]}")
        end
      end
    else
      stream_error_messages(object)
    end
  end

  private

  def find_user_user_alert
    @user_user_alert = UserUserAlert.find_by(id: params[:id])
  end
end
