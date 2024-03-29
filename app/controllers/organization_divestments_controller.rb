class OrganizationDivestmentsController < ApplicationController
  before_action :authenticate_user!

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
end
