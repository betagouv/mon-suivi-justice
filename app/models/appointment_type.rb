class AppointmentType < ApplicationRecord
  has_paper_trail

  WITH_SLOT_TYPES = ["Sortie d'audience SAP", "Sortie d'audience SPIP"].freeze

  has_many :notification_types, inverse_of: :appointment_type, dependent: :destroy
  has_many :slot_types, inverse_of: :appointment_type, dependent: :destroy
  has_many :slots

  has_many :place_appointment_types, dependent: :destroy
  has_many :places, through: :place_appointment_types

  accepts_nested_attributes_for :notification_types

  validates :name, presence: true

  scope :with_slot_types, -> { where name: WITH_SLOT_TYPES }

  def summon_notif
    notification_types.find_by(role: :summon)
  end

  def reminder_notif
    notification_types.find_by(role: :reminder)
  end

  def cancelation_notif
    notification_types.find_by(role: :cancelation)
  end

  def no_show_notif
    notification_types.find_by(role: :no_show)
  end

  def reschedule_notif
    notification_types.find_by(role: :reschedule)
  end

  def used_at_bex?
    ["Sortie d'audience SAP", "Sortie d'audience SPIP"]
  end

  def used_at_sap?
    ["Sortie d'audience SAP", 'RDV de suivi JAP', 'SAP débat contradictoire', 'Rdv JAPAT']
  end

  def used_at_spip?
    ["Sortie d'audience SPIP", '1er RDV SPIP', 'RDV de suivi SPIP', 'Convocation 741-1',
     'Placement TIG/TNR', 'Visite à domicile', 'RDV téléphonique', 'RDV DDSE', 'Convocation stage']
  end

  def sortie_audience?
    ["Sortie d'audience SAP", "Sortie d'audience SPIP"].include? name
  end

  def assignable_to_spip_current_user?
    (['1er RDV SPIP', 'RDV de suivi SPIP', 'RDV DDSE', 'RDV téléphonique',
      'Visite à domicile'].include? name) && (%w[cpip psychologist overseer].include? current_user.role)
  end

  def with_slot_types?
    WITH_SLOT_TYPES.include? name
  end
end
