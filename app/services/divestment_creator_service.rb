# app/services/divestment_creator.rb
class DivestmentCreatorService
  attr_reader :convict, :user, :divestment

  def initialize(convict, user, divestment)
    @convict = convict
    @user = user
    @divestment = divestment
  end

  def call
    state = divestment_state

    ActiveRecord::Base.transaction do
      save_divestment(state)
      create_organization_divestments(@divestment, state)
      @convict.update_organizations_for_bex_user(@user)
    end
    { state: }
  end

  private

  def divestment_state
    if @convict.discarded? || @convict.last_appointment_at_least_6_months_old?
      'auto_accepted'
    else
      'pending'
    end
  end

  def save_divestment(state)
    @divestment.assign_attributes(
      state:
    )
    @divestment.decision_date = Time.zone.now if state == 'auto_accepted'
    @divestment.save!
  end

  def create_organization_divestments(divestment, state)
    @convict.organizations.each do |org|
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
    return 'auto_accepted' if org.spip? && @convict.organizations.intersect?(org.tjs)

    org.users.where(role: 'local_admin').empty? ? 'ignored' : state
  end

  def initial_comment(state)
    case state
    when 'auto_accepted'
      I18n.t('organization_divestment.comment.auto_accepted')
    when 'ignored'
      I18n.t('organization_divestment.comment.ignored')
    end
  end
end
