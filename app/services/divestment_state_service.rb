class DivestmentStateService
  def initialize(organization_divestment, user)
    @organization_divestment = organization_divestment
    @divestment = organization_divestment.divestment
    @convict = @divestment.convict
    @target_organizations = [@divestment.organization, *@divestment.organization.linked_organizations]
    @user = user
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def accept(comment = nil, auto_accepted: false)
    return false unless @convict.valid?
    return false unless @organization_divestment.unanswered? && @divestment.pending?

    ActiveRecord::Base.transaction do
      return false unless comment.nil? || @organization_divestment.update!(comment:)

      auto_accepted ? @organization_divestment.auto_accept! : @organization_divestment.accept!
      handle_divestment_state
    end
  rescue ActiveRecord::RecordInvalid
    false
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # rubocop:disable Metrics/CyclomaticComplexity
  def refuse(comment = nil)
    return false unless @convict.valid?
    return false unless @organization_divestment.unanswered? && @divestment.pending?

    ActiveRecord::Base.transaction do
      return false unless comment.nil? || @organization_divestment.update!(comment:)

      @organization_divestment.refuse!
      return false unless @divestment.refuse!

      handle_undecided_divestment
      organizations = @convict.organizations - @target_organizations
      @convict.update!(organizations:)
      send_refuse_email
      true
    end
  rescue ActiveRecord::RecordInvalid
    false
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def ignore
    return false unless @convict.valid?
    return false unless @organization_divestment.pending? && @divestment.pending?

    @organization_divestment.ignore
  end

  private

  def handle_undecided_divestment
    return unless @divestment.refused?

    @divestment.organization_divestments.where(state: :pending).each do |organization_divestment|
      organization_divestment.ignore!
      organization_divestment.update(comment: 'ignorée car le dessaisissement a été refusé')
    end
  end

  def handle_divestment_state
    return true unless @divestment.all_accepted?

    @divestment.accept!

    @convict.update!(organizations: @target_organizations, user: nil)
    UserMailer.with(divestment: @divestment).divestment_accepted.deliver_later
    true
  end

  def send_refuse_email
    return unless @user

    UserMailer.with(divestment: @divestment, organization_divestment: @organization_divestment,
                    current_user: @user).divestment_refused.deliver_later
  end
end
