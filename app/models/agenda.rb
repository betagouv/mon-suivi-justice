class Agenda < ApplicationRecord
  include Discard::Model

  belongs_to :place
  has_many :slots, dependent: :destroy
  has_many :slot_types, dependent: :destroy

  validates :name, presence: true

  delegate :appointment_type_with_slot_types, to: :place
  delegate :organization, to: :place

  scope :in_organization, ->(organization) { joins(:place).where(place: { organization: organization }) }

  scope :in_departments, lambda { |departments|
    ids = departments.map(&:id)
    joins(place: { organization: :areas_organizations_mappings })
      .where(areas_organizations_mappings: { area_type: 'Department', area_id: ids }).distinct
  }

  scope :with_open_slots_for_date, lambda { |date, appointment_type|
    joins(:slots).where('slots.date = ? AND slots.appointment_type_id = ?', date, appointment_type.id)
                 .uniq
  }

  scope :with_open_slots, lambda { |appointment_type|
    joins(:slots).where('slots.appointment_type_id = ?', appointment_type.id).uniq
  }

  def appointment_type_with_slot_types?
    appointment_type_with_slot_types.length.positive?
  end

  def slots_for_date(date, appointment_type)
    slots.includes(:appointments).where(date: date, appointment_type: appointment_type)
         .order(:date, :starting_time)
         .uniq
  end
end
