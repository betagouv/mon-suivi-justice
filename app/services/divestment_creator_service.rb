# app/services/divestment_creator.rb
class DivestmentCreatorService
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
    @divestment.save!
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
