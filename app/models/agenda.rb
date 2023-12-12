class Agenda < ApplicationRecord
  include Discard::Model

  belongs_to :place
  has_many :slots, dependent: :destroy
  has_many :slot_types, dependent: :destroy
  has_many :appointments, through: :slots

  validates :name, presence: true

  delegate :appointment_type_with_slot_types, to: :place
  delegate :organization, to: :place

  scope :in_organization, ->(organization) { joins(place: :appointment_types).where(place: { organization: }) }

  scope :in_jurisdiction, lambda { |user_organization|
    joins(:place).where(place: { organization: [user_organization, *user_organization.linked_organizations] })
  }

  scope :linked_with_ddse, lambda { |user_organization|
    joins(place: :appointment_types)
      .where(place: { organization: user_organization.linked_organizations, appointment_types: { name: 'SAP DDSE' } })
  }

  scope :with_open_slots_for_date, lambda { |date, appointment_type|
    joins(:slots).where('slots.date = ? AND slots.appointment_type_id = ?', date, appointment_type.id)
                 .uniq
  }

  scope :with_open_slots, lambda { |appointment_type|
    joins(:slots).where('slots.appointment_type_id = ?', appointment_type.id).uniq
  }

  def self.ransackable_attributes(_auth_object = nil)
    %w[place_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[]
  end

  def appointment_type_with_slot_types?
    appointment_type_with_slot_types.length.positive?
  end

  def slots_for_date(date, appointment_type)
    slots.available_or_with_appointments(date, appointment_type)
         .order(:date, :starting_time)
         .distinct
  end
end
