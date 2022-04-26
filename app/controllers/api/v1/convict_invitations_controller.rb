module Api
  module V1
    class ConvictInvitationsController < ApiController
      def update
        @convict = Convict.find(params[:convict_id])
        raise ActiveRecord::RecordNotFound unless @convict.present?

        @convict.update(timestamp_convict_interface_creation: Time.zone.now)
      end
    end
  end
end
