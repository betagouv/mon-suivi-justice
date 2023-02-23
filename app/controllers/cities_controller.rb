class CitiesController < ApplicationController
  before_action :authenticate_user!

  def services
    @city = City.find(city_params[:city_id])
    authorize @city

    @services = []

    @tj = @city.tj&.organization
    @spip = @city.spip&.organization

    @services << @tj unless @tj.nil?
    @services << @spip unless @spip.nil?
    render json: @services
  end

  private

  def city_params
    params.permit(:city_id)
  end
end
