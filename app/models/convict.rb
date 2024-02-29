class Convict < ApplicationRecord
  include NormalizedPhone
  include Discard::Model
  include PgSearch::Model

  has_paper_trail
  normalizes :last_name, with: ->(last_name) { last_name&.strip&.upcase }
  normalizes :first_name, with: ->(first_name) { first_name&.strip&.capitalize }
  normalizes :appi_uuid, with: ->(appi_uuid) { appi_uuid&.strip }

  DOB_UNIQUENESS_MESSAGE = I18n.t('activerecord.errors.models.convict.attributes.dob.taken')

  has_many :convicts_organizations_mappings
  has_many :organizations, through: :convicts_organizations_mappings

  has_many :appointments, dependent: :destroy
  has_many :history_items, dependent: :destroy

  has_many :areas_convicts_mappings, dependent: :destroy
  has_many :departments, through: :areas_convicts_mappings, source: :area, source_type: 'Department'
  has_many :jurisdictions, through: :areas_convicts_mappings, source: :area, source_type: 'Jurisdiction'

  belongs_to :user, optional: true

  belongs_to :city, optional: true
  belongs_to :creating_organization, class_name: 'Organization', optional: true

  alias cpip user
  alias agent user

  attr_accessor :place_id, :duplicates, :current_user

  validates :appi_uuid, allow_blank: true, uniqueness: true

  validates :first_name, :last_name, :invitation_to_convict_interface_count, presence: true
  validates :phone, presence: true, unless: proc { refused_phone? || no_phone? }
  validate :phone_uniqueness
  validate :mobile_phone_number, unless: proc { refused_phone? || no_phone? }

  validate :either_city_homeless_lives_abroad_present, if: proc { current_user&.can_use_inter_ressort? }

  validates_uniqueness_of :date_of_birth, allow_nil: true, scope: %i[first_name last_name],
                                          case_sensitive: false, message: DOB_UNIQUENESS_MESSAGE,
                                          on: :appi_import

  validates :date_of_birth, presence: true, unless: proc { current_user&.admin? }
  validate :date_of_birth_date_cannot_be_in_the_past

  validates :organizations, presence: true
  validate :unique_organizations

  validate :appi_format

  after_update :update_convict_api
  after_destroy :delete_convict_from_node_app, if: :timestamp_convict_interface_creation

  scope :with_phone, -> { where.not(phone: '') }
  scope :never_invited, -> { where(invitation_to_convict_interface_count: 0) }
  scope :with_past_appointments, (lambda do
    joins(appointments: :slot).where(appointments: { slots: { date: ..Date.today } })
  end)

  pg_search_scope :search_by_name_and_phone, against: { last_name: 'A', first_name: 'B', phone: 'C' },
                                             using: {
                                               tsearch: { prefix: true }
                                             },
                                             ignoring: :accents

  delegate :name, to: :cpip, allow_nil: true, prefix: true

  def self.delete_delay
    18.month.ago
  end

  def self.archive_delay
    12.month.ago
  end

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

  def can_receive_sms?
    !(phone.blank? || no_phone? || refused_phone?)
  end

  def invitable_to_convict_interface?
    can_receive_sms? && invitation_to_convict_interface_count < 2 &&
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
    return if refused_phone? || no_phone?

    return if Convict.where(phone:).where.not(id:).empty?

    errors.add :phone, I18n.t('activerecord.errors.models.convict.attributes.phone.taken')
  end

  def date_of_birth_date_cannot_be_in_the_past
    return unless date_of_birth.present? && date_of_birth >= Date.today

    errors.add(:date_of_birth, I18n.t('activerecord.errors.models.convict.attributes.dob.not_in_the_future'))
  end

  def either_city_homeless_lives_abroad_present
    return unless city_id.blank? && homeless.blank? && lives_abroad.blank?

    errors.add(:base, I18n.t('activerecord.errors.models.convict.attributes.city.all_blanks'))
  end

  def check_duplicates
    duplicates = find_duplicates
    self.duplicates = duplicates
  end

  def update_convict_api
    UpdateConvictPhoneJob.perform_later(id) if saved_change_to_phone? && can_access_convict_inferface?
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def update_organizations(current_user, autosave: true)
    city = City.find(city_id) if city_id
    source = city&.organizations&.any? ? city : current_user

    source.organizations.each do |organization|
      ignore_japat = organization.organization_type == 'tj' && japat
      next if ignore_japat || organizations.include?(organization)

      organizations.push organization
    end

    tj_paris = Organization.find_by(name: 'TJ Paris')
    organizations.push(tj_paris) if japat && organizations.exclude?(tj_paris)

    save if autosave
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def find_duplicates
    name_conditions = 'lower(first_name) = ? AND lower(last_name) = ?'
    prefixed_phone = PhonyRails.normalize_number(phone, country_code: 'FR')

    duplicates = Convict.kept.where(name_conditions, first_name.downcase, last_name.downcase)
                        .where('phone = ? OR (date_of_birth = ? AND phone IS NOT NULL)', prefixed_phone, date_of_birth)
                        .where.not(id:)

    duplicates = duplicates.where(appi_uuid: nil) if appi_uuid.present?

    duplicates
  end

  def already_invited_to_interface?
    invitation_to_convict_interface_count.positive?
  end
  
  def appi_format
    return unless appi_uuid.present?
    return if appi_uuid.start_with?('199', '200', '201', '202')

    errors.add(:appi_uuid, I18n.t('activerecord.errors.models.convict.attributes.appi_uuid.invalid'))

  end

  private

  def unique_organizations
    return unless organizations.uniq.length != organizations.length

    errors.add(:organizations,
               I18n.t('activerecord.errors.models.convict.attributes.organizations.multiple_uniqueness'))
  end

  def delete_convict_from_node_app
    DeleteConvictJob.perform_later(id)
  end
end
