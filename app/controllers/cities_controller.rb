class CitiesController < ApplicationController
  before_action :authenticate_user!

  def services
    @city = City.find(city_params[:city_id])
    authorize @city

    @services = []

    @tj = @city.srj_tj&.organization
    @spip = @city.srj_spip&.organization

    @services << @tj unless @tj.nil?
    @services << @spip unless @spip.nil?
    render json: @services
  end

  def search
    @cities = City.search_by_name(params[:city_name])
    authorize @cities
    render layout: false
  end

  private

  def city_params
    params.permit(:city_id)
  end
end
