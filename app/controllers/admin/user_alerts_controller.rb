module Admin
  class UserAlertsController < Admin::ApplicationController
    def index
      render locals: {
        resources: [],
        search_term: '',
        page: '',
        show_search_bar: show_search_bar?
      }
    end

    def create
      UserAlertDeliveryJob.perform_later(params[:comment], params[:organization_id], params[:role], current_user)

      redirect_to admin_user_alerts_path, notice: I18n.t('admin.user_alerts.create.notice')
    end

    private

    def show_search_bar?
      false
    end
  end
end
