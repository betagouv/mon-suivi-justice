class CitiesController < ApplicationController
  before_action :authenticate_user!

  def services
    @city = City.find(city_params[:city_id])
    authorize @city

    @tj = @city.tj.organization
    @spip = @city.spip.organization

    @services = [tj: @tj, spip: @spip]

    render json: @services
  end

  private

  def city_params
    params.permit(:city_id)
  end
end
