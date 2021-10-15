class AreasOrganizationsMappingsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    mapping = AreasOrganizationsMapping.find params[:id]
    authorize mapping

    mapping.destroy
    redirect_to edit_organization_path(mapping.organization)
  end

  def create
    mapping = AreasOrganizationsMapping.new areas_organizations_mapping_params
    authorize mapping

    mapping.save
    redirect_to edit_organization_path(mapping.organization)
  end

  private

  def areas_organizations_mapping_params
    params.require(:areas_organizations_mapping).permit(:organization_id, :area_id, :area_type)
  end
end
