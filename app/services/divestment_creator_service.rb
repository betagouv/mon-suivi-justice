# app/services/divestment_creator.rb
class DivestmentCreatorService
  attr_reader :convict, :user, :divestment

  def initialize(convict, user, divestment)
    @convict = convict
    @user = user
    @divestment = divestment
    @destinations = [@divestment.organization, *@divestment.organization.linked_organizations]
  end

  def call
    state = divestment_state

    ActiveRecord::Base.transaction do
      save_divestment(state)
      create_organization_divestments(@divestment, state)
      if state == 'auto_accepted'
        @convict.update(organizations: @destinations, user: nil)
      else
        @convict.update_organizations_for_bex_user(@user, @destinations)
      end
    end
    { state: }
  end

  private

  def divestment_state
    return 'auto_accepted' if auto_acceptable_divestment?

    'pending'
  end

  def save_divestment(state)
    @divestment.assign_attributes(
      state:
    )
    @divestment.decision_date = Time.zone.now if state == 'auto_accepted'
    @divestment.save!
    @divestment.record_history_for_transition(:accept) if @divestment.auto_accepted?
  end

  def create_organization_divestments(divestment, state)
    old_orgs = @convict.organizations - @destinations
    old_orgs.each do |org|
      org_state = initial_state(org, state)
      attributes = {
        divestment_id: divestment.id,
        organization_id: org.id,
        state: org_state,
        comment: initial_comment(org_state)
      }

      # Add decision_date if org_state is not 'pending'
      attributes[:decision_date] = Time.zone.now unless org_state == 'pending'

      OrganizationDivestment.create!(attributes)
    end
  end

  def initial_state(org, state)
    return state unless state == 'pending'
    return 'ignored' if org.local_admin.empty?

    if org.spip? && @convict.organizations.intersect?(org.tjs) && @convict.tj.map(&:local_admin).flatten.present?
      return 'auto_accepted'
    end

    state
  end

  def initial_comment(state)
    case state
    when 'auto_accepted'
      I18n.t('organization_divestment.comment.auto_accepted')
    when 'ignored'
      I18n.t('organization_divestment.comment.ignored')
    end
  end

  def auto_acceptable_divestment?
    return false if @convict.invalid?

    @convict.discarded? || @convict.last_appointment_at_least_6_months_old?
  end
end
