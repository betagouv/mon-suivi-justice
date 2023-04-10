class AreasConvictsMappingsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_mapping, only: :destroy

  def destroy
    authorize @mapping

    @mapping.destroy
    flash[:notice] = 'Les rattachements de la ppsmj ont bien été mis à jour'

    # If current_user can no longer see the convict, redirect the user to the convicts index
    convict = policy_scope(Convict).find_by_id(@mapping.convict.id)

    if convict.present?
      redirect_to edit_convict_path(@mapping.convict)
    else
      redirect_to convicts_path
    end
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

  def find_mapping
    @mapping = AreasConvictsMapping.find params[:id]
  end
end
