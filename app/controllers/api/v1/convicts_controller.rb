module Api
  module V1
    class ConvictsController < ApiController
      def show
        @convict = Convict.find(params[:id])
        @sorted_appointments = @convict.appointments.joins(:slot).order('slots.date ASC, slots.starting_time ASC')
      end

      def cpip
        @convict = Convict.find(params[:convict_id])
        @cpip = @convict.user
        raise ActiveRecord::RecordNotFound unless @cpip.present?
      end
    end
  end
end
