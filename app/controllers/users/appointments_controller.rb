class Users::AppointmentsController < ApplicationController
    before_action :authenticate_user!

    # Faire le test dans feature
    def index
        @appointments = policy_scope([:users, Appointment]).page(params[:page]).per(25)
        authorize @appointments
    end
end