class SecurityCharterAcceptancesController < ApplicationController
  before_action :authenticate_user!

  def new
    authorize :security_charter_acceptance
  end

  def create
    authorize :security_charter_acceptance
    if current_user.update(security_charter_accepted_at: Time.zone.now)
      redirect_to root_path, notice: t('.notice')
    else
      render :new, status: :unprocessable_entity
    end
  end
end
