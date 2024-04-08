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
    handle_divestment_state
  end

  def refuse
    return false unless @organization_divestment.pending? && @divestment.pending?

    @organization_divestment.refuse

    return unless @divestment.refuse

    handle_undecided_divestment
    organizations = @convict.organizations - @target_organizations
    @convict.update(organizations:)

    if @current_user
      AdminMailer.with(divestment: @divestment, organization_divestment: @organization_divestment,
                       current_user: @user).divestment_refused.deliver_later
    end

    true
  end

  def ignore
    return false unless @organization_divestment.pending? && @divestment.pending?

    @organization_divestment.ignore
    handle_divestment_state
  end

  private

  def handle_undecided_divestment
    return unless @divestment.refused?

    @divestment.organization_divestments.where(state: :pending).each do |organization_divestment|
      organization_divestment.ignore
      organization_divestment.update(comment: 'orga divestment ignored because divestment was refused')
    end
  end

  def handle_divestment_state
    return true unless @divestment.all_accepted?

    @divestment.accept

    @convict.update(organizations: @target_organizations, user: nil)
    UserMailer.with(divestment: @divestment).divestment_accepted.deliver_later
    true
  end
end
