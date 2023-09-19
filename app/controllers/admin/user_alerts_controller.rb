module Admin
  class UserAlertsController < Admin::ApplicationController
    def create
      UserAlertDeliveryJob.perform_later(resource_params[:user_alert][:content], resource_params[:organization_id],
                                         resource_params[:role], current_user)

      redirect_to admin_user_alerts_path, notice: I18n.t('admin.user_alerts.create.notice')
    end

    def resource_params
      params.permit(:organization_id, :role, user_alert: [:read_at, :content])
    end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
