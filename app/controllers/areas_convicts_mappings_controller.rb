class AreasConvictsMappingsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    mapping = AreasConvictsMapping.find params[:id]
    authorize mapping

    mapping.destroy
    redirect_to edit_convict_path(mapping.convict)
  end

  def create
    mapping = AreasConvictsMapping.new areas_convicts_mapping_params
    authorize mapping

    mapping.save
    redirect_to edit_convict_path(mapping.convict)
  end

  private

  def areas_convicts_mapping_params
    params.require(:areas_convicts_mapping).permit(:convict_id, :area_id, :area_type)
  end
end
