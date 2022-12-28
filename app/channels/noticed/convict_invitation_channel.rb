module Noticed
  class ConvictInvitationChannel < ApplicationCable::Channel
    def subscribed
      stream_for current_user
    end

    def unsubscribed
      stop_all_streams
    end

    def mark_all_as_read()
      p "============"
      p "mark all user_notificastion as read for user #{current_user.id}"
      p "============"
      current_user.user_notifications.mark_as_read!
    end
  end
end
