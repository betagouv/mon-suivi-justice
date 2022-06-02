module Users
  class AppointmentsController < ApplicationController
    before_action :handle_search_query, only: :index

    def index
      respond_to do |format|
        format.html
        format.pdf do
          render template: 'appointments/index_pdf.html.erb',
                 pdf: 'Liste des rdv', footer: { right: '[page]/[topage]' }
        end
      end
      authorize @appointments
    end

    private

    def handle_search_query
      @q = policy_scope([:users, Appointment]).active.ransack(params[:q])
      @result = @q.result(distinct: true)
                  .joins(:convict, slot: [:appointment_type,
                                          { agenda: [:place] }])
                  .includes(:convict, slot: [:appointment_type,
                                             { agenda: [:place] }])
      @appointments = @result.page(params[:page]).per(25)
    end
  end
end
