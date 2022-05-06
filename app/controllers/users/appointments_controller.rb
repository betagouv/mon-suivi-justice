module Users
  class AppointmentsController < ApplicationController
    def index
      @appointments = policy_scope([:users, Appointment])
                      .order('slots.date DESC, slots.starting_time DESC')
                      .page(params[:page]).per(25)
      authorize @appointments
    end
  end
end
