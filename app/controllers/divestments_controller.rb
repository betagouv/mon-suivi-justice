# app/controllers/divestments_controller.rb
class DivestmentsController < ApplicationController
  def create # rubocop:disable Metrics/AbcSize
    divestment = Divestment.new(user_id: current_user.id, organization_id: current_organization.id)
    authorize divestment

    begin
      convict = Convict.find(params[:convict_id])
      divestment.convict_id = convict.id

      divestment_creation = DivestmentCreatorService.new(convict, current_user, divestment).call
      redirect_after_creation(convict, divestment_creation[:state])
    rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
      redirect_to new_convict_path, alert: t('divestments.create.error', error: e.message)
    end
  end

  private

  def redirect_after_creation(convict, state = 'pending')
    redirect_to determine_path(convict), notice: determine_notice(convict, state)
  end

  def determine_path(convict, state)
    return convicts_path if convict.invalid?
    return new_appointment_path(convict_id: convict.id) if current_user.work_at_bex?
    return convict_path(convict) if state == 'auto_accepted'

    convicts_path
  end

  def determine_notice(convict, state)
    if state == 'auto_accepted'
      t('divestments.create.auto_accepted')
    elsif current_user.work_at_bex?
      convict.valid? ? t('divestments.create.success_bex') : t('divestments.create.invalid_for_bex')
    else
      t('divestments.create.success')
    end
  end
end
