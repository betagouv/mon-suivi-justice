module Api
  module V1
    class ConvictInvitationsController < ApiController
      def update
        @convict = Convict.find(params[:convict_id])
        raise ActiveRecord::RecordNotFound unless @convict.present?

        if @convict.update(timestamp_convict_interface_creation: Time.zone.now)
          render json: @convict
        else
          render json: @convict.errors, status: :unprocessable_entity
        end
      end
    end
  end
end
