module Api
  module V1
    class ConvictsController < ApiController

      before_action :get_convict

      def show
      end

      def get_agent
        @agent = @convict.agent


        raise ActiveRecord::RecordNotFound unless @agent.present?
      end

      private

      def get_convict
        @convict = Convict.find(params[:id])

        raise ActiveRecord::RecordNotFound unless @convict.present?
      end
    end
  end
end
