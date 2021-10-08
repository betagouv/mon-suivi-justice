class Department < ApplicationRecord
  validates :name, uniqueness: true, presence: true, inclusion:   { in: FRENCH_DEPARTMENTS.map(&:name) }
  validates :number, uniqueness: true, presence: true, inclusion: { in: FRENCH_DEPARTMENTS.map(&:number) }
end
