class HandleStalledDivestmentsJob < ApplicationJob
  def perform
    DivestmentStalledService.new.call
  end
end
