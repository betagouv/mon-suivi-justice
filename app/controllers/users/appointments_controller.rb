module Users
  class AppointmentsController < ApplicationController
    def index
      @q = policy_scope([:users, Appointment]).active.ransack(params[:q])

      @all_appointments = @q.result(distinct: true)
      .joins(:convict, slot: [:appointment_type, { agenda: [:place] }])
      .includes(:convict, slot: [:appointment_type, { agenda: [:place] }])
      .order('slots.date ASC, slots.starting_time ASC')

      @appointments = @all_appointments.page(params[:page]).per(25)

      respond_to do |format|
        format.html do
          render 'appointments/index'
        end
        format.pdf do
          render template: 'appointments/index_pdf.html.erb',
          pdf: 'Liste des rdv', footer: { right: '[page]/[topage]' }
        end
      end
      authorize @appointments
    end
  end
end
