module DataCollector
  class Base
    def initialize(organization_id: nil, full_stats: true)
      @organization = Organization.find(organization_id) if organization_id.present?
      @full_stats = full_stats
    end
  end
end
