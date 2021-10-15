class BexController < ApplicationController
  before_action :authenticate_user!

  def agenda_jap
    current_date = params.key?(:date) ? params[:date] : Date.today.next_occurring(:friday)

    @appointments = policy_scope(Appointment).for_a_date(current_date).active
                                             .joins(slot: [:appointment_type, :agenda])
                                             .where(appointment_type: { name: 'RDV BEX SAP' })
                                             .group('appointments.id,agendas.name')

    authorize @appointments
  end

  def agenda_spip
    @current_month = params.key?(:month) ? params[:month].to_date : Date.today

    @appointments = policy_scope(Appointment).for_a_month(@current_month).active
                                             .joins(slot: [:appointment_type, :agenda])
                                             .where(appointment_type: { name: 'RDV BEX SPIP' })

    authorize @appointments
  end
end
