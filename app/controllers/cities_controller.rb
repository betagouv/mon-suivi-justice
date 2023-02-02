class CitiesController < ApplicationController
    before_action :authenticate_user!

    def services
        @city = City.find(city_params[:city_id])


        

        authorize @city

        render json: @city
    end

    private

    def city_params
        params.permit(:city_id)
    end
end