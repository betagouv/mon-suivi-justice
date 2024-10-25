class AppointmentType < ApplicationRecord
  has_paper_trail

  WITH_SLOT_TYPES = ["Sortie d'audience SAP", "Sortie d'audience SPIP", 'SAP DDSE'].freeze
  ALLOWED_ON_WEEKENDS = ['Placement TIG/TNR', 'Convocation DDSE'].freeze
  SPIP_ASSIGNABLE = ['1ère convocation de suivi SPIP', 'Convocation de suivi SPIP', 'Convocation 741-1',
                     'Placement TIG/TNR', 'Visite à domicile', 'RDV téléphonique', 'Convocation DDSE',
                     'Convocation stage', 'Convocation rappel SPIP', 'Action collective'].freeze

  has_many :notification_types, inverse_of: :appointment_type, dependent: :destroy
  has_many :slot_types, inverse_of: :appointment_type, dependent: :destroy
  has_many :slots

  has_many :place_appointment_types, dependent: :destroy
  has_many :places, through: :place_appointment_types

  has_and_belongs_to_many :extra_fields

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
      ["Sortie d'audience SAP", "Sortie d'audience SPIP", 'Convocation de suivi JAP', 'SAP débat contradictoire',
       'Convocation JAPAT', 'SAP DDSE']
    end

    def used_by_local_admin_tj?
      used_at_sap?
    end

    def used_at_spip?
      [*SPIP_ASSIGNABLE, "Sortie d'audience SPIP", 'SAP DDSE']
    end

    def ransackable_attributes(_auth_object = nil)
      %w[name]
    end
  end

  def ddse?
    name == 'SAP DDSE'
  end

  def used_at_bex?
    self.class.used_at_bex?.include? name
  end

  def used_at_sap?
    self.class.used_at_sap?.include? name
  end

  def used_by_local_admin_tj?
    self.class.used_by_local_admin_tj?.include? name
  end

  def sortie_audience?
    ["Sortie d'audience SAP", "Sortie d'audience SPIP", 'SAP DDSE'].include? name
  end

  def sortie_audience_without_ddse?
    ["Sortie d'audience SAP", "Sortie d'audience SPIP"].include? name
  end

  def sortie_audience_sap?
    name == "Sortie d'audience SAP"
  end

  def sortie_audience_spip?
    name == "Sortie d'audience SPIP"
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
