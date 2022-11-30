# To deliver this notification:
#
# ConvictInvitationNotification.with(post: @post).deliver_later(current_user)
# ConvictInvitationNotification.with(post: @post).deliver(current_user)

class ConvictInvitationNotification < Noticed::Base
  # Add your delivery methods
  #
  deliver_by :database, association: :user_notifications
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  param :invitation_params
  param :status

  # Define helper methods to make rendering easier.
  #
  def message
    t(".convict_invitations.create.invitation_sent")
  end
  #
  # def url
  #   post_path(params[:post])
  # end
end
