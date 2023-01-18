class ExtraField < ApplicationRecord
  DATA_TYPES = { text: 'texte', date: 'date' }.freeze
  belongs_to :organization
  enum data_type: DATA_TYPES
  validates :name, presence: true
  validates :data_type, presence: true
end
