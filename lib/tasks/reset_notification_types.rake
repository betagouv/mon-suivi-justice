require 'ruby-progressbar'

desc 'reset notification_types templates to default'
task reset_notification_types: :environment do
  progress = ProgressBar.create(total: AppointmentType.count * Organization.count * NotificationType.roles.count)

  AppointmentType.all.each do |at|
    default = NotificationType.where(appointment_type: at)

    Organization.all.each do |o|
      NotificationType.roles.each_key do |role|
        old_notif_type = NotificationType.where(organization: o, role: role, appointment_type: at)
        old_notif_type.first.destroy if old_notif_type.first.present?

        new_notif_type = default.where(role: role).first.dup
        new_notif_type.organization = o
        new_notif_type.is_default = false
        new_notif_type.save!

        progress.increment
      end
    end
  end
end
