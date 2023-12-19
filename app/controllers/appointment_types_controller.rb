class AppointmentTypesController < ApplicationController
  before_action :authenticate_user!

  def index
    @appointment_types = AppointmentType.all.order('name asc')
    @organizations = Organization.all.order(:name)
    @organization = params[:orga] ? Organization.find(params[:orga]) : nil

    authorize @appointment_types
  end

  def edit
    setup_edit

    authorize @appointment_type
  end

  def update
    setup_update
    authorize @appointment_type

    old_templates = @notification_types.pluck(:role, :template)

    if @appointment_type.update(appointment_type_params)
      check_default_and_update(old_templates)
      redirect_to appointment_types_path, notice: t('.notice')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def setup_edit
    @appointment_type = AppointmentType.find(params[:id])
    @organization = Organization.find(params[:orga]) if params[:orga].present?
    @notification_types = NotificationType.where(appointment_type: @appointment_type, organization: @organization)
  end

  def setup_update
    @appointment_type = AppointmentType.find(params[:id])
    @organization = Organization.find(appointment_type_params[:orga]) if appointment_type_params[:orga].present?
    @notification_types = NotificationType.where(appointment_type: @appointment_type, organization: @organization)
  end

  def check_default_and_update(old_templates)
    @notification_types.each do |nt|
      old_template = old_templates.find { |l| l[0] == nt.role }[-1]

      if nt.is_default && nt.template != old_template
        notif_types = NotificationType.where(appointment_type: @appointment_type, role: nt.role, still_default: true)
        notif_types.update_all(template: nt.template)
      elsif nt.template != old_template
        nt.update(still_default: false)
      end
    end
  end

  def appointment_type_params
    params.require(:appointment_type).permit(
      :name, :orga, notification_types_attributes: [:id, :template, :reminder_period]
    )
  end
end
