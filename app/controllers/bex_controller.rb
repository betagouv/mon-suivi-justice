class BexController < ApplicationController
  def agenda_jap
    current_date = params.key?(:date) ? params[:date] : Date.today.next_occurring(:friday)

    @appointments = Appointment.for_a_date(current_date)
                               .joins(slot: [:appointment_type, :agenda])
                               .where(appointment_type: { name: 'RDV BEX SAP' })
                               .group('agendas.name,appointments.id')

    authorize @appointments
  end

  def agenda_spip
    @current_month = params.key?(:month) ? params[:month].to_date : Date.today

    @appointments = Appointment.for_a_month(@current_month)
                               .joins(slot: [:appointment_type, :agenda])
                               .where(appointment_type: { name: 'RDV BEX SPIP' })

    authorize @appointments
  end
end
