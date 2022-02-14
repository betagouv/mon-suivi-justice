class Convict < ApplicationRecord
  include NormalizedPhone
  include Discard::Model
  has_paper_trail

  has_many :appointments, dependent: :destroy
  has_many :history_items, dependent: :destroy

  has_many :areas_convicts_mappings, dependent: :destroy
  has_many :departments, through: :areas_convicts_mappings, source: :area, source_type: 'Department'
  has_many :jurisdictions, through: :areas_convicts_mappings, source: :area, source_type: 'Jurisdiction'

  attr_accessor :place_id

  validates :appi_uuid, allow_blank: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  validates :phone, presence: true, unless: proc { refused_phone? || no_phone? }
  validate :mobile_phone_number, unless: proc { refused_phone? || no_phone? }

  #
  # Convict linked to same departement OR same jurisdiction than the user's organization ones
  #
  scope :under_hand_of, lambda { |organization|
    dpt_id = Organization.joins(:areas_organizations_mappings)
                         .where(id: organization, areas_organizations_mappings: { area_type: 'Department' })
                         .select('areas_organizations_mappings.area_id')
    juri_id = Organization.joins(:areas_organizations_mappings)
                          .where(id: organization, areas_organizations_mappings: { area_type: 'Jurisdiction' })
                          .select('areas_organizations_mappings.area_id')
    Convict.joins(:areas_convicts_mappings)
           .where(areas_convicts_mappings: { area_type: 'Department', area_id: dpt_id })
           .or(
             Convict.joins(:areas_convicts_mappings)
                    .where(areas_convicts_mappings: { area_type: 'Jurisdiction', area_id: juri_id })
           ).distinct
  }

  scope :in_department, lambda { |department|
    joins(:areas_convicts_mappings)
      .where(areas_convicts_mappings: { area_type: 'Department', area_id: department.id })
  }

  scope :with_phone, -> { where.not(phone: '') }

  def name
    "#{last_name.upcase} #{first_name.capitalize}"
  end

  def identity
    return name unless phone.present?

    "#{last_name.upcase} #{first_name.capitalize} - #{unormalized_phone}"
  end

  def profile_path
    Rails.application.routes.url_helpers.convict_path(id)
  end

  def future_appointments
    appointments.joins(:slot)
                .where(state: 'booked')
                .where('slots.date': Date.today..)
  end

  def passed_appointments
    appointments.joins(:slot)
                .where(state: 'booked')
                .where('slots.date': ..Date.today)
  end

  def unormalized_phone
    phone.gsub("+33", "0")
  end

  def mobile_phone_number
    return unless phone && !phone.start_with?('+336', '+337')

    errors.add :phone, I18n.t('activerecord.errors.models.convict.attributes.phone.mobile')
  end
end
