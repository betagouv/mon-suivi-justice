# rails r scripts/populate_notification_types.rb

Organization.all.each { |orga| orga.setup_notification_types }

p 'NotificationType populated'
