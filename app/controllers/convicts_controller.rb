class ConvictsController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = Convict.ransack(params[:q])
    @convicts = @q.result(distinct: true).page params[:page]
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

  def edit
    @convict = Convict.find(params[:id])
    authorize @convict
  end

  def update
    @convict = Convict.find(params[:id])
    authorize @convict

    if @convict.update(convict_params)
      redirect_to convicts_path
    else
      render :edit
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
    params.require(:convict).permit(:first_name, :last_name, :phone, :no_phone,
                                    :refused_phone, :place_id)
  end

  def select_path(params)
    if params[:commit] == "Enregistrer\r\net prendre RDV"
      new_appointment_path(convict_id: @convict.id)
    else
      convicts_path
    end
  end
end
