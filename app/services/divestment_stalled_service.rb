class DivestmentStalledService
  def call
    manage_old_pending_divestments
    remind_local_admins_of_divestments
  end

  private

  def manage_old_pending_divestments
    OrganizationDivestment.old_pending.each do |organization_divestment|
      convict = organization_divestment.convict
      service = DivestmentStateService.new(organization_divestment, nil)
      if divestmentable?(convict, organization_divestment)
        service.accept("Accepté automatiquement après 10 jours d'attente", auto_accepted: true)
      end
    end
  end

  def remind_local_admins_of_divestments
    to_be_reminded = Organization.with_divestment_to_be_reminded

    to_be_reminded.each do |organization|
      UserMailer.notify_local_admins_of_divestment(organization).deliver_later
      update_to_be_reminded(organization)
    end
  end

  def update_to_be_reminded(organization)
    organization.organization_divestments.reminders_due.each do |od|
      od.update!(last_reminder_email_at: Time.zone.now)
    end
  end

  def divestmentable?(convict, organization_divestment)
    organization = organization_divestment.divestment.organization
    convict.archived? || convict.no_future_appointments_outside_organization_and_links?(organization)
  end
end
