class UserAlertNotification < Noticed::Base
  deliver_by :database, association: :user_alerts
end
