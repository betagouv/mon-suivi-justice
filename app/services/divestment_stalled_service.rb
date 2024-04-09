class DivestmentStalledService
  def initialize
    @organization_divestments = OrganizationDivestment.old_pending
  end

  def call
    @organization_divestments.each do |organization_divestment|
      convict = organization_divestment.convict
      service = DivestmentStateService.new(organization_divestment, nil)
      return service.accept if divestmentable?(convict)

      service.ignore
    end
  end

  private

  def divestmentable?(convict)
    convict.archived? || convict.last_appointment_at_least_3_months_old?
  end
end
