# app/controllers/divestments_controller.rb
class DivestmentsController < ApplicationController
  def create
    @divestment = Divestment.new(divestment_params)
    @divestment.organization_from_id = current_user.organization.id
    if @divestment.save
      redirect_to some_path, notice: 'La déssaisissement a bien été créé.'
    else
      @organizations = Organization.all
      @convicts = Convict.all
      render :new
    end
  end

  private

  def divestment_params
    params.require(:divestment).permit(:user_id, :organization_to_id, :decision_date, :comment)
  end
end
