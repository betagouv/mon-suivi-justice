module Api
  module V1
    class ConvictsController < ApiController

      before_action :get_convict

      def show
      end

      def get_cpip
        @cpip = @convict.user
        raise ActiveRecord::RecordNotFound unless @cpip.present?
      end

      private

      def get_convict
        @convict = Convict.find(params[:id])

        render json: @convict

        raise ActiveRecord::RecordNotFound unless @convict.present?
      end
    end
  end
end
