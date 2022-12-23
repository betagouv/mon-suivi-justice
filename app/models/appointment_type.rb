class AppointmentType < ApplicationRecord
  has_paper_trail

  WITH_SLOT_TYPES = ["Sortie d'audience SAP", "Sortie d'audience SPIP", 'SAP DDSE'].freeze
  ALLOWED_ON_WEEKENDS = ['Placement TIG/TNR'].freeze
  SPIP_ASSIGNABLE = ['1er RDV SPIP', 'RDV de suivi SPIP', 'Convocation 741-1',
                     'Placement TIG/TNR', 'Visite à domicile', 'RDV téléphonique', 'RDV DDSE', 'Convocation stage',
                     'Convocation rappel SPIP', 'Action collective'].freeze

  has_many :notification_types, inverse_of: :appointment_type, dependent: :destroy
  has_many :slot_types, inverse_of: :appointment_type, dependent: :destroy
  has_many :slots

  has_many :place_appointment_types, dependent: :destroy
  has_many :places, through: :place_appointment_types

  accepts_nested_attributes_for :notification_types
  attr_accessor :orga

  validates :name, presence: true

  scope :with_slot_types, -> { where name: WITH_SLOT_TYPES }
  scope :assignable, -> { where name: SPIP_ASSIGNABLE }

  class << self
    def used_at_bex?
      ["Sortie d'audience SAP", "Sortie d'audience SPIP"]
    end

    def used_at_sap?
      ["Sortie d'audience SAP", 'RDV de suivi JAP', 'SAP débat contradictoire', 'RDV JAPAT', 'SAP DDSE']
    end

    def used_at_spip?
      [*SPIP_ASSIGNABLE, "Sortie d'audience SPIP", 'SAP DDSE']
    end
  end

  def sortie_audience?
    ["Sortie d'audience SAP", "Sortie d'audience SPIP", 'SAP DDSE'].include? name
  end

  def assignable?
    SPIP_ASSIGNABLE.include? name
  end

  def with_slot_types?
    WITH_SLOT_TYPES.include? name
  end

  def allowed_on_weekends?
    ALLOWED_ON_WEEKENDS.include? name
  end
end
