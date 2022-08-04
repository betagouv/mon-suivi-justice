class AppointmentType < ApplicationRecord
  has_paper_trail

  WITH_SLOT_TYPES = ["Sortie d'audience SAP", "Sortie d'audience SPIP"].freeze
  ASSIGNABLE = ['1er RDV SPIP', 'RDV de suivi SPIP', 'RDV DDSE', 'RDV téléphonique',
                'Visite à domicile'].freeze

  has_many :notification_types, inverse_of: :appointment_type, dependent: :destroy
  has_many :slot_types, inverse_of: :appointment_type, dependent: :destroy
  has_many :slots

  has_many :place_appointment_types, dependent: :destroy
  has_many :places, through: :place_appointment_types

  accepts_nested_attributes_for :notification_types
  attr_accessor :orga

  validates :name, presence: true

  scope :with_slot_types, -> { where name: WITH_SLOT_TYPES }
  scope :assignable, -> { where name: ASSIGNABLE }

  def used_at_bex?
    ["Sortie d'audience SAP", "Sortie d'audience SPIP"]
  end

  def used_at_sap?
    ["Sortie d'audience SAP", 'RDV de suivi JAP', 'SAP débat contradictoire', 'Rdv JAPAT']
  end

  def used_at_spip?
    ["Sortie d'audience SPIP", '1er RDV SPIP', 'RDV de suivi SPIP', 'Convocation 741-1',
     'Placement TIG/TNR', 'Visite à domicile', 'RDV téléphonique', 'RDV DDSE', 'Convocation stage',
     'Convocation rappel SPIP', 'Action collective']
  end

  def sortie_audience?
    ["Sortie d'audience SAP", "Sortie d'audience SPIP"].include? name
  end

  def assignable?
    ASSIGNABLE.include? name
  end

  def with_slot_types?
    WITH_SLOT_TYPES.include? name
  end
end
