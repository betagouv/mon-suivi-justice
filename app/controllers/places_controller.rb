class PlacesController < ApplicationController
  before_action :authenticate_user!

  def index
    @places = policy_scope(Place).kept.order(:name).includes(:organization).page params[:page]
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
      create_agenda(@place)
      redirect_to places_path
    else
      render :new, status: :unprocessable_entity
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
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    @place = Place.find(params[:place_id])
    authorize @place

    @place.discard
    @place.agendas.discard_all
    @place.agendas.each do |agenda|
      agenda.slot_types.discard_all
    end

    redirect_to places_path
  end

  private

  def place_params
    params.require(:place).permit(
      :name, :adress, :phone, :contact_email, :main_contact_method,
      :organization_id, :preparation_link,
      agendas_attributes: [:id, :name, :_destroy],
      appointment_type_ids: []
    )
  end

  def create_agenda(place)
    Agenda.create!(place:, name: "Agenda #{place.name}")
  end
end
