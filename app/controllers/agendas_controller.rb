class AgendasController < ApplicationController
  before_action :authenticate_user!

  def update
    agenda = Agenda.find params[:id]
    authorize agenda

    agenda.update agenda_params
    redirect_to edit_place_path(agenda.place)
  end

  def create
    agenda = Agenda.new agenda_params
    authorize agenda

    agenda.save
    redirect_to edit_place_path(agenda.place)
  end

  private

  def agenda_params
    params.require(:agenda).permit(:place_id, :name)
  end
end
