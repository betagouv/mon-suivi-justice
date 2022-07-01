class AppointmentTypesController < ApplicationController
  before_action :authenticate_user!

  def index
    @appointment_types = AppointmentType.all.order('name asc')
    @organizations = Organization.all

    authorize @appointment_types
  end

  def edit
    setup_edit

    authorize @appointment_type
  end

  def update
    setup_edit
    authorize @appointment_type

    if @appointment_type.update(appointment_type_params)
      redirect_to appointment_types_path, notice: t('.notice')
    else
      render :edit
    end
  end

  private

  def setup_edit
    @appointment_type = AppointmentType.find(params[:id])
    @organization = Organization.find(params[:orga]) if params[:orga].present?
    @notification_types = NotificationType.where(appointment_type: @appointment_type, organization: @organization)
  end

  def appointment_type_params
    params.require(:appointment_type).permit(
      :name, :orga, notification_types_attributes: [:id, :template, :reminder_period]
    )
  end
end
