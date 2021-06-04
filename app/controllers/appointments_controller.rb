class AppointmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @appointments = Appointment.all
  end
end
