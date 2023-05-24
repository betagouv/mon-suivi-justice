class SrjSpip < ApplicationRecord
  belongs_to :organization, optional: true
  has_many :cities

  def short_name
    name.gsub(/Service Pénitentiaire d'Insertion et de Probation/, 'SPIP')
  end
end
