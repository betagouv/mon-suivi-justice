class PlacesController < ApplicationController
  before_action :authenticate_user!

  def index
    @places = policy_scope(Place).page params[:page]
    authorize @places
  end

  def new
    @place = Place.new
    authorize @place
  end

  def create
    @place = Place.new(place_params)
    authorize @place

    if @place.save
      redirect_to places_path
    else
      render :new
    end
  end

  def edit
    @place = Place.find(params[:id])
    authorize @place
  end

  def update
    @place = Place.find(params[:id])
    authorize @place

    if @place.update(place_params)
      redirect_to places_path
    else
      render :edit
    end
  end

  def destroy
    @place = Place.find(params[:id])
    authorize @place

    @place.destroy
    redirect_to places_path
  end

  private

  def place_params
    params.require(:place).permit(
      :name, :adress, :phone, :contact_email, :main_contact_method, :organization_id,
      agendas_attributes: [:id, :name, :_destroy],
      appointment_type_ids: []
    )
  end
end
