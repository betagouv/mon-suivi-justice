# app/controllers/divestments_controller.rb
class DivestmentsController < ApplicationController
  def create
    convict = Convict.find_by(id: params[:convict_id])
    authorize :divestment, :create?

    return redirect_to convicts_path, alert: t('divestments.create.failure') unless convict

    DivestmentCreator.new(convict, current_user).call
    redirect_after_creation(convict)
  end

  private

  def redirect_after_creation(convict)
    notice = current_user.work_at_bex? ? t('divestments.create.success_bex') : t('divestments.create.success')
    path = current_user.work_at_bex? ? new_appointment_path(convict_id: convict.id) : convicts_path
    redirect_to path, notice:
  end
end
