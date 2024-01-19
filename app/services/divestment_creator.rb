# app/services/divestment_creator.rb
class DivestmentCreator
  def initialize(convict, user)
    @convict = convict
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      state = divestment_state
      divestment = create_divestment(state)
      create_organization_divestments(divestment, state)
      @convict.update_organizations_for_bex_user(@user)
    end
  end

  private

  def divestment_state
    if @convict.discarded? || @convict.last_appointment_at_least_6_months_old?
      'accepted'
    else
      'pending'
    end
  end

  def create_divestment(state)
    Divestment.create!(
      convict_id: @convict.id,
      user_id: @user.id,
      organization_id: @user.organization.id,
      state:
    )
  end

  def create_organization_divestments(divestment, state)
    @convict.organizations.each do |org|
      org_state = org.users.where(role: 'local_admin').empty? ? 'ignored' : state
      OrganizationDivestment.create!(
        divestment_id: divestment.id,
        organization_id: org.id,
        state: org_state
      )
    end
  end
end
