class AppointmentType < ApplicationRecord
  has_paper_trail

  has_many :notification_types, inverse_of: :appointment_type, dependent: :destroy
  has_many :slot_types, inverse_of: :appointment_type, dependent: :destroy
  has_many :slots

  has_many :place_appointment_types, dependent: :destroy
  has_many :places, through: :place_appointment_types

  accepts_nested_attributes_for :notification_types

  validates :name, presence: true

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

  def used_at_bex?
    ['RDV BEX SAP', 'RDV BEX SPIP'].include? name
  end

  def used_at_sap?
    ['RDV BEX SAP', 'RDV de suivi SAP'].include? name
  end

  def used_at_spip?
    ['RDV BEX SPIP', '1er RDV SPIP', 'RDV de suivi SPIP'].include? name
  end
end
