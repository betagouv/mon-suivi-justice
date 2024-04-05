class DivestmentStateService
  def initialize(organization_divestment, user)
    @organization_divestment = organization_divestment
    @divestment = organization_divestment.divestment
    @convict = @divestment.convict
    @target_organizations = [@divestment.organization, *@divestment.organization.linked_organizations]
    @user = user
  end

  def accept
    return false unless @organization_divestment.pending? && @divestment.pending?

    @organization_divestment.accept
    return true unless @divestment.all_accepted?

    @divestment.accept

    @convict.update(organizations: @target_organizations, user: nil)
    AdminMailer.with(convict: @convict, target_organizations: @target_organizations).divestment_accepted.deliver_later
    true
  end

  def refuse
    return false unless @organization_divestment.pending? && @divestment.pending?

    @organization_divestment.refuse
    @divestment.refuse

    organizations = @convict.organizations - @target_organizations
    @convict.update(organizations:)
    AdminMailer.with(divestment: @divestment, organization_divestment: @organization_divestmentl, current_user: @user).divestment_refused.deliver_later

    true
  end
end