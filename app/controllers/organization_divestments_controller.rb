class OrganizationDivestmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization_divestment, only: [:show, :edit, :update]

  # rubocop:disable Metrics/AbcSize
  def index
    @organization_divestments = policy_scope(OrganizationDivestment)
    authorize @organization_divestments
    @current_orga_divestments = @organization_divestments.unanswered.order(created_at: :desc).page params[:page]
    @past_orga_divestments = @organization_divestments.answered.order(decision_date: :desc).page params[:page]

    @divestments = policy_scope(Divestment)
    @current_divestments = @divestments.where(state: :pending).order(created_at: :desc).page params[:page]
    @past_divestments = @divestments.where.not(state: :pending).order(decision_date: :desc).page params[:page]
  end
  # rubocop:enable Metrics/AbcSize

  def edit
    authorize @organization_divestment
  end

  # rubocop:disable Metrics/AbcSize
  def update
    authorize @organization_divestment
    state_service = DivestmentStateService.new(@organization_divestment, current_user)
    comment = organization_divestment_params[:comment]
    success = case params[:transition]
              when I18n.t('organization_divestments.edit.accept')
                state_service.accept(comment)
              when I18n.t('organization_divestments.edit.refuse')
                state_service.refuse(comment)
              else
                false
              end

    if success
      redirect_to organization_divestments_path, notice: notice_message(params[:transition])
    else
      render :edit
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def set_organization_divestment
    @organization_divestment = OrganizationDivestment.find(params[:id])
  end

  def organization_divestment_params
    params.require(:organization_divestment).permit(:comment)
  end

  def notice_message(transition)
    case transition
    when I18n.t('organization_divestments.edit.accept')
      I18n.t('organization_divestments.edit.accept_notice')
    when I18n.t('organization_divestments.edit.refuse')
      I18n.t('organization_divestments.edit.refuse_notice')
    else
      I18n.t('organization_divestments.edit.invalid_notice')
    end
  end
end
