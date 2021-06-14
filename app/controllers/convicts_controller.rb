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
      redirect_to select_path(params)
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

  def select_path(params)
    if params[:commit] == I18n.t('new_convict_first_appointment')
      new_appointment_path(convict_id: @convict.id)
    else
      convicts_path
    end
  end
end
