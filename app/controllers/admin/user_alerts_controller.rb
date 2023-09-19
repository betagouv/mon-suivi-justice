module Admin
  class UserAlertsController < Admin::ApplicationController
    def create
      UserAlertDeliveryJob.perform_later(params[:user_alert][:content], params[:organization_id],
                                         params[:role], params[:alert_type], current_user)

      redirect_to admin_user_alerts_path, notice: I18n.t('admin.user_alerts.create.notice')
    end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
