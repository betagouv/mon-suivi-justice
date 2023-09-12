# To deliver this notification:
#
# UserAlertNotification.with(post: @post).deliver_later(current_user)
# UserAlertNotification.with(post: @post).deliver(current_user)

class UserAlertNotification < Noticed::Base
  # Add your delivery methods
  #
  deliver_by :database, association: :user_alerts
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  # param :post

  # Define helper methods to make rendering easier.
  #
  # def message
  #   t(".message")
  # end
  #
  # def url
  #   post_path(params[:post])
  # end
end
