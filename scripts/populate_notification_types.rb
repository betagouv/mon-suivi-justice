# rails r scripts/populate_notification_types.rb

roles = NotificationType.roles.keys
all_default = NotificationType.where(organization: nil)

Organization.all.each do |orga|
  AppointmentType.all.each do |apt_type|
    templates = orga.notification_types.where(appointment_type: apt_type)
    default = all_default.where(appointment_type: apt_type)

    roles.each do |role|
      if templates.where(role: role).empty?
        new_template = default.where(role: role).first.dup
        new_template.organization = orga
        new_template.save!
      end
    end
  end
end

p 'NotificationType populated'
