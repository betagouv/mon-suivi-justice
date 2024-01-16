# app/controllers/divestments_controller.rb
class DivestmentsController < ApplicationController
  def create
    convict = Convict.find_by(id: params[:convict_id])
    authorize :divestment, :create?

    return redirect_to convicts_path, alert: t('divestments.create.failure') unless convict

    create_divestments_for_convict(convict)
    redirect_after_creation(convict)
  end

  private

  def create_divestments_for_convict(convict)
    ActiveRecord::Base.transaction do
      divestment = create_divestment(convict)
      create_organization_divestments(divestment, convict)
      update_convict_organizations(convict)
    end
  rescue ActiveRecord::RecordInvalid => e
    # TODO: Handle error (back to convicts/new ?)
    Rails.logger.error("Erreur lors de la création des dessaisissements: #{e.message}")
  end

  def create_divestment(convict)
    Divestment.create!(
      convict_id: convict.id,
      user_id: current_user.id,
      organization_id: current_user.organization.id,
      state: 'pending'
    )
  end

  def create_organization_divestments(divestment, convict)
    convict.organizations.each do |org|
      OrganizationDivestment.create!(
        divestment_id: divestment.id,
        organization_id: org.id,
        state: 'pending'
      )
    end
  end

  def update_convict_organizations(convict)
    return unless current_user.work_at_bex?

    convict.organizations << current_user.organizations
  end

  def redirect_after_creation(convict)
    path = current_user.work_at_bex? ? new_appointment_path(convict_id: convict.id) : convicts_path
    redirect_to path, success: t('divestments.create.success')
  end

  # def divestment_params
  #   params.require(:divestment).permit(:user_id, :organization_to_id, :decision_date)
  # end
end
