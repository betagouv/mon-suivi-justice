module DeploymentEnvironment
  extend ActiveSupport::Concern

  included do
    def real_production?
      ENV['APP'] == 'mon-suivi-justice-production'
    end
  end
end
