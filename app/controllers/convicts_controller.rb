class ConvictsController < ApplicationController
  before_action :authenticate_user!

  def index
    @convicts = Convict.all
    authorize @convicts
  end

  def new
    @convict = Convict.new
    authorize @convict

    @convict.appointments.build
  end

  def create
    @convict = Convict.new(convict_params)
    authorize @convict

    if @convict.save
      redirect_to new_first_appointment_path(@convict.id, convict_params[:place_id])
    else
      render :new
    end
  end

  def destroy
    @convict = Convict.find(params[:id])
    authorize @convict

    @convict.destroy
    redirect_to convicts_path
  end

  private

  def convict_params
    params.require(:convict).permit(:first_name, :last_name, :phone, :place_id)
  end
end
