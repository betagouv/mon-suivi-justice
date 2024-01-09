# app/controllers/divestments_controller.rb
class DivestmentsController < ApplicationController
  def create
    convict = Convict.find_by(id: params[:convict_id])
    authorize :divestment, :create?

    if convict
      create_divestments_for_convict(convict)
      redirect_to convicts_path, success: 'Les demandes des dessaisissements ont bien été créées.'
    else
      redirect_to convicts_path, alert: "Le probationnaire n'existe pas"
    end
  end

  private

  def create_divestments_for_convict(convict)
    user_organization = current_user.organization

    ActiveRecord::Base.transaction do
      convict.organizations.each do |org|
        Divestment.create!(
          convict_id: convict.id,
          user_id: current_user.id,
          organization_from_id: org.id,
          organization_to_id: user_organization.id,
          state: 'pending'
        )
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    # TODO : Handle error (back to convicts/new ?)
    Rails.logger.error("Error creating divestments: #{e.message}")
  end

  def divestment_params
    params.require(:divestment).permit(:user_id, :organization_to_id, :decision_date, :comment)
  end
end
