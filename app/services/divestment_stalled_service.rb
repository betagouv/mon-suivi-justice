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

    reminders_due = OrganizationDivestment.reminders_due

    reminders_due.each do |organization_divestment|
      UserMailer.notify_local_admins_of_divestment(organization_divestment).deliver_later
    end
  end

  private

  def divestmentable?(convict)
    convict.archived? || convict.last_appointment_at_least_3_months_old?
  end
end
