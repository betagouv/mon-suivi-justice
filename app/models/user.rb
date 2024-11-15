class User < ApplicationRecord
  include NormalizedPhone
  include PgSearch::Model

  has_paper_trail

  belongs_to :organization
  belongs_to :headquarter, optional: true
  has_many :convicts, dependent: :nullify
  has_many :appointments, dependent: :nullify
  has_many :invited_appointments, class_name: 'Appointment', foreign_key: :inviter_user_id, dependent: :nullify
  has_many :visits, class_name: 'Ahoy::Visit'
  has_many :user_user_alerts, dependent: :destroy
  has_many :user_alerts, through: :user_user_alerts
  has_many :unread_user_alerts, -> { where(user_user_alerts: { read_at: nil }) },
           through: :user_user_alerts, source: :user_alert
  has_many :divestments, dependent: :nullify

  # Include default devise modules. Others available are:
  # :confirmable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :timeoutable,
         :recoverable, :rememberable, :secure_validatable, :lockable

  enum role: {
    admin: 0,
    bex: 1,
    cpip: 2,
    local_admin: 4,
    prosecutor: 5,
    jap: 6,
    secretary_court: 7,
    dir_greff_bex: 8,
    greff_co: 9,
    dir_greff_sap: 10,
    greff_sap: 11,
    educator: 12,
    psychologist: 13,
    overseer: 14,
    dpip: 15,
    secretary_spip: 16,
    greff_tpe: 17,
    greff_crpc: 18,
    greff_ca: 19
  }

  BEX_ROLES = %w[prosecutor greff_co dir_greff_bex bex greff_tpe greff_crpc greff_ca].freeze
  SAP_ROLES = %w[jap secretary_court greff_sap dir_greff_sap].freeze
  SPIP_ROLES = %w[dpip cpip educator psychologist overseer secretary_spip].freeze
  TJ_ROLES = (SAP_ROLES + BEX_ROLES).freeze
  ORDERED_ROLES = %w[admin local_admin jap bex prosecutor secretary_court dir_greff_bex greff_co greff_tpe greff_crpc
                     greff_ca dir_greff_sap greff_sap dpip cpip secretary_spip educator psychologist overseer].freeze
  ORDERED_TJ_ROLES = ORDERED_ROLES & TJ_ROLES
  ORDERED_SPIP_ROLES = ORDERED_ROLES & SPIP_ROLES
  DIVESTMENT_ROLES = %w[local_admin greff_sap jap dir_greff_sap secretary_spip].freeze

  after_invitation_accepted :trigger_brevo_create_job
  after_update_commit :trigger_brevo_update_job, if: :relevant_field_changed?
  after_destroy_commit { DeleteContactInBrevoJob.perform_later(email) }

  validates :first_name, :last_name, presence: true
  validates :share_email_to_convict, inclusion: { in: [true, false] }
  validates :share_phone_to_convict, inclusion: { in: [true, false] }
  validate :correct_role_for_organization_type

  before_validation :set_default_role

  scope :in_organization, ->(organization) { where(organization:) }
  scope :with_divestment_roles, -> { where(role: DIVESTMENT_ROLES) }

  pg_search_scope :search_by_name, against: %i[first_name last_name],
                                   using: {
                                     tsearch: { prefix: true }
                                   }

  delegate :name, to: :organization, prefix: true
  delegate :all_local_admins, to: :organization
  delegate :in_jurisdiction?, to: :organization

  def name(reverse: false)
    return "#{last_name.upcase} #{first_name.capitalize}" unless reverse

    "#{first_name.capitalize} #{last_name.upcase}"
  end

  def identity
    return name unless phone.present?

    "#{name} - #{phone.phony_formatted.delete(' ')}"
  end

  def work_at_bex?
    BEX_ROLES.include? role
  end

  def work_at_sap?
    SAP_ROLES.include? role
  end

  def work_at_tj?
    work_at_bex? || work_at_sap? || local_admin_tj?
  end

  def work_at_spip?
    SPIP_ROLES.include?(role) || local_admin_spip?
  end

  def local_admin_spip?
    local_admin? && organization.spip?
  end

  def local_admin_tj?
    local_admin? && organization.tj?
  end

  def profile_path
    Rails.application.routes.url_helpers.user_path(id)
  end

  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/AbcSize
  def can_invite_to_convict_interface?(convict = nil)
    return true if admin?

    # Permet de gérer les policies pour l'invitation lors de la création d'un probationnaire
    if convict
      ((dpip? || local_admin? || secretary_spip? || work_at_sap?) && belongs_to_convict_organizations?(convict)) ||
        (cpip? && convict.user_id == id)
    else
      dpip? || cpip? || local_admin? || secretary_spip? || work_at_sap?
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize

  def can_have_appointments_assigned?
    %w[cpip psychologist overseer].include? role
  end

  def organizations
    [organization, *organization.linked_organizations]
  end

  def can_use_inter_ressort?
    work_at_bex? && organization.use_inter_ressort?
  end

  def too_many_appointments_without_status?
    recent_past_booked_appointments_count = appointments
                                            .joins(:slot)
                                            .where(state: 'booked')
                                            .where('slots.date >= ? AND slots.date < ?', 3.months.ago, Date.today)
                                            .count

    recent_past_booked_appointments_count > 5
  end

  def security_charter_accepted?
    security_charter_accepted_at && security_charter_accepted_at < Time.zone.now
  end

  def can_follow_convict?
    cpip? || dpip? || local_admin_spip?
  end

  def can_manage_divestments?
    local_admin? || greff_sap? || jap? || dir_greff_sap? || secretary_spip?
  end

  private

  def set_default_role
    self.role ||= organization.tj? ? 'greff_sap' : 'cpip'
  end

  def trigger_brevo_create_job
    CreateContactInBrevoJob.perform_later(id)
  end

  def trigger_brevo_update_job
    UpdateContactInBrevoJob.perform_later(id)
  end

  def relevant_field_changed?
    %i[role organization_id first_name last_name email].any? { |attr| saved_change_to_attribute?(attr) }
  end

  def belongs_to_convict_organizations?(convict)
    convict.organizations.include?(organization)
  end

  def correct_role_for_organization_type
    return if admin? || role_matches_organization?

    errors.add(:role, I18n.t('activerecord.errors.models.user.attributes.role.correct_for_organization'))
  end

  def role_matches_organization?
    (organization&.spip? && work_at_spip?) || (organization&.tj? && work_at_tj?)
  end
end
