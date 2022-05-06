module Users
  class AppointmentsController < ApplicationController

    def index
      @appointments = policy_scope([:users, Appointment]).page(params[:page]).per(25)
      authorize @appointments
    end
  end
end
