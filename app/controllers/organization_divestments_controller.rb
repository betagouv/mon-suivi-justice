class OrganizationDivestmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization_divestment, only: [:show, :edit, :update]

  def index
    @organization_divestments = policy_scope(OrganizationDivestment).order(:created_at)
    authorize @organization_divestments
    @current_orga_divestments = @organization_divestments.where(state: :pending).page params[:page]
    @past_orga_divestments = @organization_divestments.where.not(state: :pending).page params[:page]

    @divestments = policy_scope(Divestment).order(:created_at)

    @current_divestments = @divestments.where(state: :pending).page params[:page]
    @past_divestments = @divestments.where.not(state: :pending).page params[:page]
  end

  def show
    authorize OrganizationDivestment
  end

  def edit
    authorize @organization_divestment
  end

  def update
    authorize @organization_divestment
    case params[:transition]
    when 'accept'
      if @organization_divestment.accept && @organization_divestment.update(organization_divestment_params)
        redirect_to organization_divestments_path, notice: 'Organization divestment was successfully accepted.'
      else
        render :edit
      end
    when 'refuse'
      if @organization_divestment.refuse && @organization_divestment.update(organization_divestment_params)
        redirect_to organization_divestments_path, notice: 'Organization divestment was successfully refused.'
      else
        render :edit
      end
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
end
