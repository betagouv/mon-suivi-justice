module DataCollector
  class Base
    def initialize(organization_id: nil, display_notifications: true)
      @organization = Organization.find(organization_id) if organization_id.present?
      @display_notifications = display_notifications
    end
  end
end
