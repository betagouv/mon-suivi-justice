# app/controllers/divestments_controller.rb
class DivestmentsController < ApplicationController
  def create # rubocop:disable Metrics/AbcSize
    convict = Convict.find_by(id: params[:convict_id])

    return redirect_to convicts_path, alert: t('divestments.create.convict_not_found') unless convict

    begin
      divestment = Divestment.new(
        convict_id: convict.id,
        user_id: current_user.id,
        organization_id: current_organization.id
      )

      authorize divestment

      DivestmentCreatorService.new(convict, current_user, divestment).call
      redirect_after_creation(convict)
    rescue ActiveRecord::RecordInvalid => e
      redirect_to new_convict_path, alert: t('divestments.create.error', error: e.message)
    end
  end

  private

  def redirect_after_creation(convict)
    notice = current_user.work_at_bex? ? t('divestments.create.success_bex') : t('divestments.create.success')
    path = current_user.work_at_bex? ? new_appointment_path(convict_id: convict.id) : convicts_path
    redirect_to path, notice:
  end
end
