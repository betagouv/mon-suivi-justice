class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def home
    @convicts = policy_scope(Convict.all)
    @users = User.count
    @notifications = Notification.where(state: ['received', 'failed']).count

    @recorded = Appointment.count
    @fulfiled = Appointment.where(state: 'fulfiled').count
    @no_show = Appointment.where(state: 'no_show').count
    @booked = Appointment.where(state: 'booked').count
    @excused = Appointment.where(state: 'excused').count
    @canceled = Appointment.where(state: 'canceled').count

    @future_booked = Appointment.where(state: 'booked').joins(:slot).where('slots.date > ?', Date.today).count
    @passed_booked = Appointment.where(state: 'booked').joins(:slot).where('slots.date < ?', Date.today).count
    @passed_no_canceled = Appointment.joins(:slot).where('slots.date < ?', Date.today)
                                     .where.not(state: 'canceled').count
  end
end
