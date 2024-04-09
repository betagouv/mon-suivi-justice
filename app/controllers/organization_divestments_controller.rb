class OrganizationDivestmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization_divestment, only: [:show, :edit, :update]

  # rubocop:disable Metrics/AbcSize
  def index
    @organization_divestments = policy_scope(OrganizationDivestment).order(:created_at)
    authorize @organization_divestments
    @current_orga_divestments = @organization_divestments.where(state: :pending).page params[:page]
    @past_orga_divestments = @organization_divestments.where.not(state: :pending).page params[:page]

    @divestments = policy_scope(Divestment).order(:created_at)

    @current_divestments = @divestments.where(state: :pending).page params[:page]
    @past_divestments = @divestments.where.not(state: :pending).page params[:page]
  end
  # rubocop:enable Metrics/AbcSize

  def edit
    authorize @organization_divestment
  end

  def update
    authorize @organization_divestment
    state_service = DivestmentStateService.new(@organization_divestment, current_user)
    success = case params[:transition]
              when 'accept'
                state_service.accept
              when 'refuse'
                state_service.refuse
              else
                false
              end

    if success && @organization_divestment.update(organization_divestment_params)
      redirect_to organization_divestments_path, notice: notice_message(params[:transition])
    else
      render :edit
    end
  end

  private

  def set_organization_divestment
    @organization_divestment = OrganizationDivestment.find(params[:id])
  end

  def organization_divestment_params
    params.require(:organization_divestment).permit(:comment)
  end

  def notice_message(transition)
    case transition
    when 'accept'
      'Organization divestment was successfully accepted.'
    when 'refuse'
      'Organization divestment was successfully refused.'
    else
      'Invalid action.'
    end
  end
end
