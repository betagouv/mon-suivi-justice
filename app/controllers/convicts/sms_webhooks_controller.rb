module Convicts
  class SmsWebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_after_action :verify_authorized

    def receive
      notification = Notification.find_by(external_id: params['messageId'])
      if notification.present? && params['msg_status'] == 'softBounces'
        SmsDeliveryJob.perform_later(notification,
                                     resent: true)
      end
      head :ok
    end
  end
end
