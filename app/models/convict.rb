class Convict < ApplicationRecord
  include NormalizedPhone
  include Discard::Model
  include PgSearch::Model
  include ActiveModel::Validations

  has_paper_trail
  normalizes :last_name, with: ->(last_name) { last_name&.strip&.upcase }
  # for firstname, we need the gsub for compose name (ex: Jean-Pierre)
  # we only modify 1st letter of each word, that's why we need the downcase first
  normalizes :first_name, with: ->(first_name) { first_name&.strip&.downcase&.gsub(/\b\w/, &:upcase) } # rubocop:disable Style/SafeNavigationChainLength
  normalizes :appi_uuid, with: ->(appi_uuid) { appi_uuid&.strip&.upcase }

  DOB_UNIQUENESS_MESSAGE = I18n.t('activerecord.errors.models.convict.attributes.dob.taken')
  ARCHIVE_DURATION = 6.months

  has_many :convicts_organizations_mappings, dependent: :destroy
  has_many :organizations, through: :convicts_organizations_mappings

  has_many :appointments, dependent: :destroy
  has_many :history_items, dependent: :destroy

  has_many :divestments, dependent: :destroy
  has_many :organization_divestments, through: :divestments

  has_many :divestments, dependent: :destroy
  has_many :organization_divestments, through: :divestments

  generates_token_for :stop_sms, expires_in: 24.hours

  belongs_to :user, optional: true

  belongs_to :city, optional: true
  belongs_to :creating_organization, class_name: 'Organization', optional: true

  alias cpip user
  alias agent user
  alias archived? discarded?

  attr_accessor :place_id, :duplicates, :current_user

  validates :appi_uuid, allow_blank: true, uniqueness: true

  validates :first_name, :last_name, :invitation_to_convict_interface_count, presence: true
  validates :phone, presence: true, unless: proc { refused_phone? || no_phone? }
  validate :phone_uniqueness, if: -> { phone.present? }
  validate :mobile_phone_number, unless: proc { refused_phone? || no_phone? }

  validate :either_city_homeless_lives_abroad_present, if: proc { current_user&.can_use_inter_ressort? }

  validate :unique_name_and_dob_unless_uuid

  validates :date_of_birth, presence: true, unless: proc { current_user&.admin? }
  validate :convict_cannot_be_under16

  validates :organizations, presence: true
  validate :unique_organizations

  validates_with AppiUuidValidator

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
  delegate :tj, to: :organizations, allow_nil: true

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
    future_appointments_with_states(['booked'])
  end

  def future_appointments_and_excused
    @future_appointments_and_excused ||= future_appointments_with_states(%w[booked excused])
  end

  def booked_appointments
    appointments.joins(:slot).with_state(:booked)
  end

  def passed_appointments
    booked_appointments
      .where('slots.date < ?', Date.today).or(passed_today_appointments)
  end

  def passed_today_appointments
    booked_appointments
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

  def convict_cannot_be_under16
    return unless date_of_birth.present? && date_of_birth >= 16.years.ago

    errors.add(:date_of_birth, I18n.t('activerecord.errors.models.convict.attributes.dob.over16'))
  end

  def either_city_homeless_lives_abroad_present
    return unless city_id.blank? && homeless.blank? && lives_abroad.blank?

    errors.add(:base, I18n.t('activerecord.errors.models.convict.attributes.city.all_blanks'))
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
      ignore_japat = organization.tj? && japat
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

  def toggle_japat_orgs
    return if in_paris_jurisdiction?

    tj_paris = Organization.find_by(name: 'TJ Paris')
    return unless tj_paris

    if japat?
      organizations << tj_paris unless organizations.include?(tj_paris)
    else
      organizations.delete(tj_paris)
    end

    save
  end

  def update_organizations_for_bex_user(user, new_orgas = nil)
    return unless user.work_at_bex?
    return unless valid?

    new_orgas ||= user.organizations
    new_orgas.each do |org|
      organizations << org unless organizations.include?(org)
    end

    save
  end

  def valid_for_user?(user)
    return true if user.admin?

    valid?
  end

  # rubocop:disable Metrics/AbcSize
  def find_duplicates
    return [] if valid?

    duplicates = []
    duplicates << Convict.where(appi_uuid:).where.not(id:) if duplicate_appi_uuid?
    duplicates << Convict.where(phone:).where.not(id:) if duplicate_phone?
    duplicates << Convict.where(first_name:, last_name:, date_of_birth:).where.not(id:) if duplicate_date_of_birth?

    duplicates.flatten.uniq
  end
  # rubocop:enable Metrics/AbcSize

  def find_dup_with_full_name_and_dob
    duplicates = Convict.where(first_name:, last_name:, date_of_birth:).where.not(id:)

    return duplicates.where(appi_uuid: [nil, '']) if appi_uuid.present?

    duplicates
  end

  def already_invited_to_interface?
    invitation_to_convict_interface_count.positive?
  end

  def unique_name_and_dob_unless_uuid
    existing_convict = Convict.where(first_name:, last_name:, date_of_birth:).where.not(id:)

    # Check if there's an existing record with the same attributes and no appi_uuid
    return unless existing_convict.exists?(appi_uuid: [nil, '']) && appi_uuid.blank?

    errors.add(:date_of_birth, DOB_UNIQUENESS_MESSAGE)
  end

  def last_appointment_at_least_6_months_old?
    last_appointment_at_least_x_months_old?(6)
  end

  def last_appointment_in_the_past?
    last_appointment_at_least_x_months_old?(0)
  end

  def pending_divestments?
    divestments.find_by(state: :pending).present?
  end

  def organization_divestments_from(organization)
    # can only be one pending divestment per organization and convict
    organization_divestments.where(state: :pending, organization:).first
  end

  def divestment_to?(organization)
    divestments.where(state: :pending, organization:).any?
  end

  def pending_divestment
    divestments.where(state: :pending).first
  end

  def duplicate_appi_uuid?
    errors.where(:appi_uuid, :taken).any?
  end

  def duplicate_phone?
    errors.where(:phone, I18n.t('activerecord.errors.models.convict.attributes.phone.taken')).any?
  end

  def duplicate_date_of_birth?
    errors.where(:date_of_birth, DOB_UNIQUENESS_MESSAGE).any?
  end

  def being_divested?
    divestments.where(state: :pending).any?
  end

  def refuse_phone
    update_refused_phone(true)
  end

  def accept_phone
    update_refused_phone(false)
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

  def in_paris_jurisdiction?
    tj_paris = Organization.find_by(name: 'TJ Paris')
    spip_paris = Organization.find_by(name: 'SPIP 75')
    paris_jurisdictions = [tj_paris, spip_paris]

    paris_jurisdictions.all? { |org| organizations.include?(org) }
  end

  def last_appointment_at_least_x_months_old?(nb_months)
    return true if appointments.empty?

    last_appointment_date = appointments.joins(:slot).maximum('slots.date')
    last_appointment_date.present? && last_appointment_date < nb_months.months.ago
  end

  def future_appointments_with_states(states)
    appointments.joins(:slot)
                .select('appointments.*, slots.date')
                .where(state: states)
                .where('slots.date': Date.today..)
                .order('slots.date')
  end

  def update_refused_phone(value)
    self.refused_phone = value
    state = save(validate: false)
    event = value ? 'refuse_phone_convict' : 'accept_phone_convict'
    create_history_item(event) if state
    state
  end

  def create_history_item(event)
    return unless HistoryItem.validate_event(event)

    HistoryItemFactory.perform(convict: self, event:, category: 'convict')
  end
end
