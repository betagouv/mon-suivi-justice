class NotificationTypesResetController < ApplicationController
  skip_after_action :verify_authorized

  def update
    notification_type = NotificationType.find(params[:id])
    authorize notification_type, :reset?
    apt_type = notification_type.appointment_type
    role = notification_type.role

    default = NotificationType.where(appointment_type: apt_type, role:, is_default: true).first

    notification_type.update(template: default.template, still_default: true)

    redirect_back(fallback_location: root_path)
  end
end
