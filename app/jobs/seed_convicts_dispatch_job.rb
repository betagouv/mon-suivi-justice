class SeedConvictsDispatchJob < ApplicationJob
  def perform
    dpt_92 = Department.find_by number: '92'
    return unless dpt_92

    Convict.find_each { |convict| AreasConvictsMapping.create convict: convict, area: dpt_92 }
  end
end
