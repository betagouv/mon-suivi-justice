module DataCollector
  class Base
    def initialize(organization_id: nil)
      @organization = Organization.find(organization_id) if organization_id.present?
    end
  end
end
