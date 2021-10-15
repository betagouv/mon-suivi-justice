class SeedDepartmentJob < ApplicationJob
  def perform
    FRENCH_DEPARTMENTS&.each do |department|
      Department.find_or_create_by name: department.name, number: department.number
    end
  end
end
