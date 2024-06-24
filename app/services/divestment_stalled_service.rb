class DivestmentStalledService
  def initialize
  end

  def call
    manage_old_pending_divestments
    remind_local_admins_of_divestments
  end

  private

  def manage_old_pending_divestments
    admin_action_needed = []

    OrganizationDivestment.old_pending.each do |organization_divestment|
      convict = organization_divestment.convict
      service = DivestmentStateService.new(organization_divestment, nil)
      if divestmentable?(convict)
        service.accept
      else
        admin_action_needed << organization_divestment
      end

      UserMailer.admin_divestment_action_needed.deliver_later if admin_action_needed.any?
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

  def divestmentable?(convict)
    convict.archived? || convict.last_appointment_at_least_3_months_old?
  end
end
