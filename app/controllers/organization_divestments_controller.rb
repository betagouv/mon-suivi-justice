class OrganizationDivestmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @organization_divestments = policy_scope(OrganizationDivestment).where(state: :pending).order(:created_at).page params[:page]
    @divestments = policy_scope(Divestment).where(state: :pending).order(:created_at).page params[:page]
    authorize @organization_divestments
  end

  def show
    authorize OrganizationDivestment
  end
end
