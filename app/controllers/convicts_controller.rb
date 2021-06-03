class ConvictsController < ApplicationController
  before_action :authenticate_user!

  def index
    @convicts = Convict.all
  end

  def new
    @convict = Convict.new
    @convict.appointments.build
  end

  def create
    @convict = Convict.new(convict_params)

    if @convict.save
      redirect_to convicts_path
    else
      render :new
    end
  end

  def destroy
    @convict = Convict.find(params[:id])
    @convict.destroy
    redirect_to convicts_path
  end

  private

  def convict_params
    params.require(:convict).permit(:first_name, :last_name, :phone,
                                    appointments_attributes: [:date, :slot])
  end
end
