module Api
  module V1
    class ConvictsController < ApiController
      def show
        @convict = Convict.find_by(phone: params[:phone])

        raise ActiveRecord::RecordNotFound unless @convict.present?
      end
    end
  end
end
