class DivestmentStateService
  def initialize(organization_divestment)
    @organization_divestment = organization_divestment
    @divestment = organization_divestment.divestment
    @convict = @divestment.convict
    @target_organization = [@target_organization, *@target_organization.linked_organizations]
  end

  def update(new_state)
    return unless @divestment.pending?

    case new_state
    when 'accept', 'auto_accept'
      accept_divestment
    when 'refuse'
      refuse_divestment
    else
      false
    end
  end

  private

  def accept_divestment
    return @organization_divestment.accept unless @divestment.all_accepted? && @divestment.accept

    @convict.update(organizations: @target_organizations, user: nil)


  end

  def refuse_divestment
    return @organization_divestment.refuse unless @divestment.refuse

    organizations = @convict.organizations - @target_organizations
    @convict.update(organizations:)
  end
end