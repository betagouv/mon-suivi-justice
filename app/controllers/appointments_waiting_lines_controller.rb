class AppointmentsWaitingLinesController < ApplicationController
  before_action :authenticate_user!

  def index
    @appointments = policy_scope(Appointment).active.page(params[:page]).per(25)
    @appointments = @appointments.where(user: current_user) if %w[cpip dpip].include?(current_user.role)

    authorize @appointments
  end
end
