class OrganizationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @organizations = Organization.all.page params[:page]
    authorize @organizations
  end

  def edit
    @organization = Organization.includes(:departments).find params[:id]
    authorize @organization
  end

  def new
    @organization = Organization.new
    authorize @organization
  end

  def update
    organization = Organization.find params[:id]
    authorize organization

    organization.update organization_params
    redirect_to organizations_path
  end

  def destroy
    organization = Organization.find params[:id]
    authorize organization

    organization.destroy
    redirect_to organizations_path
  end

  def create
    organization = Organization.new organization_params
    authorize organization

    organization.save
    redirect_to organizations_path
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :jap_modal_content, :organization_type)
  end
end
