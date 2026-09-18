class ExecuteStoredProceduresJob < ApplicationJob
  def perform
    connection = ActiveRecord::Base.connection
    connection.exec_query('call update_model_probationnaire()')
    connection.exec_query('call update_model_appointments()')
    connection.exec_query('call update_model_sms()')
  end
end
