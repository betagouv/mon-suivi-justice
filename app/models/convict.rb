class Convict < ApplicationRecord
  include NormalizedPhone
  include Discard::Model
  has_paper_trail

  WHITELISTED_PHONES = %w[+33659763117 +33683481555 +33682356466 +33603371085
                          +33687934479 +33674426177 +33616430756 +33613254126].freeze

  has_many :appointments, dependent: :destroy
  has_many :history_items, dependent: :destroy

  has_many :areas_convicts_mappings, dependent: :destroy
  has_many :departments, through: :areas_convicts_mappings, source: :area, source_type: 'Department'
  has_many :jurisdictions, through: :areas_convicts_mappings, source: :area, source_type: 'Jurisdiction'

  belongs_to :user, optional: true
  alias_attribute :cpip, :user
  alias_attribute :agent, :user

  attr_accessor :place_id, :duplicates

  validates :appi_uuid, allow_blank: true, uniqueness: true
  validates :first_name, :last_name, :invitation_to_convict_interface_count, presence: true
  validates :phone, presence: true, unless: proc { refused_phone? || no_phone? }
  validate :phone_uniqueness
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
    joins(:areas_convicts_mappings)
      .where(areas_convicts_mappings: { area_type: 'Department', area_id: dpt_id })
      .or(
        joins(:areas_convicts_mappings)
               .where(areas_convicts_mappings: { area_type: 'Jurisdiction', area_id: juri_id })
      ).distinct
  }

  scope :in_department, lambda { |department|
    joins(:areas_convicts_mappings)
      .where(areas_convicts_mappings: { area_type: 'Department', area_id: department.id })
  }

  scope :in_departments, lambda { |departments|
    ids = departments.map(&:id)
    joins(:areas_convicts_mappings)
      .where(areas_convicts_mappings: { area_type: 'Department', area_id: ids })
  }

  scope :with_phone, -> { where.not(phone: '') }
  scope :never_invited, -> { where(invitation_to_convict_interface_count: 0) }
  scope :with_past_appointments, (lambda do
    joins(appointments: :slot).where(appointments: { slots: { date: ..Date.today } })
  end)

  delegate :name, to: :cpip, allow_nil: true, prefix: true

  def name
    "#{last_name.upcase} #{first_name.capitalize}"
  end

  def identity
    return name unless phone.present?

    "#{name} - #{phone.phony_formatted.delete(' ')}"
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
                .where('slots.date < ?', Date.today).or(passed_today_appointments)
  end

  def passed_today_appointments
    appointments.joins(:slot)
                .where(state: 'booked')
                .where('slots.date = ?', Date.today)
                .where('starting_time <= ?', Time.now.strftime('%H:%M'))
  end

  def mobile_phone_number
    return unless phone && !phone.start_with?('+336', '+337')

    errors.add :phone, I18n.t('activerecord.errors.models.convict.attributes.phone.mobile')
  end

  def phone_whitelisted?
    WHITELISTED_PHONES.include?(phone)
  end

  def invitable_to_convict_interface?
    phone.present? && invitation_to_convict_interface_count < 2 &&
      timestamp_convict_interface_creation.nil?
  end

  def can_access_convict_inferface?
    timestamp_convict_interface_creation.present?
  end

  def interface_invitation_state
    return :accepted if can_access_convict_inferface?
    return :reinvited if invitation_to_convict_interface_count > 1
    return :invited if invitation_to_convict_interface_count == 1

    :not_invited
  end

  def phone_uniqueness
    return if refused_phone? || no_phone? || phone_whitelisted?

    return if Convict.where(phone: phone).where.not(id: id).empty?

    errors.add :phone, I18n.t('activerecord.errors.models.convict.attributes.phone.taken')
  end

  def check_duplicates(current_user)
    homonyms = Convict.where(
      'lower(first_name) = ? AND lower(last_name) = ?',
      first_name.downcase, last_name.downcase
    ).where.not(id: id)

    homonyms = homonyms.where(appi_uuid: nil) if appi_uuid.present?
    homonyms = check_duplicates_without_phones(homonyms, current_user)

    self.duplicates = homonyms
  end

  def check_duplicates_without_phones(homonyms, current_user)
    current_department = current_user.organization.departments.first
    homonyms = homonyms.in_department(current_department) if refused_phone? || no_phone?

    homonyms = homonyms.reject do |i|
      (i.refused_phone? || i.no_phone?) && i.departments.first != current_department
    end

    Convict.where(id: homonyms.pluck(:id))
  end
end
