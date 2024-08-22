class OrganizationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @organizations = policy_scope(Organization).order(name: :asc).page params[:page]
    authorize @organizations
  end

  def edit
    @organization = Organization.find params[:id]
    authorize @organization
  end

  def new
    @organization = Organization.new
    authorize @organization
  end

  def update
    @organization = Organization.find params[:id]
    authorize @organization

    if @organization.update organization_params
      redirect_to edit_organization_path(@organization), notice: 'Service mis à jour avec succès.'
    else
      @organization.errors.each { |error| flash.now[:alert] = error.message }
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    organization = Organization.new organization_params
    authorize organization

    organization.save
    organization.setup_notification_types
    redirect_to edit_organization_path(organization), notice: 'Service créé avec succès.'
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :jap_modal_content, :organization_type, :time_zone, :mail,
                                         { extra_fields_attributes: [:id, :name, :data_type, :scope, :_destroy,
                                                                     { appointment_type_ids: [] }] })
  end
end
