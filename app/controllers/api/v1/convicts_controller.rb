module Api
  module V1
    class ConvictsController < ApiController
      def show
        @convict = Convict.find(params[:id])
      end
    end
  end
end
