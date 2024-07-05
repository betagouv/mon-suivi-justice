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
  has_many :divestments

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

  after_invitation_accepted { CreateContactInBrevoJob.perform_later(id) }
  after_update_commit :trigger_brevo_update_job, if: :relevant_field_changed?
  after_destroy_commit { DeleteContactInBrevoJob.perform_later(email) }

  validates :first_name, :last_name, presence: true
  validates :share_email_to_convict, inclusion: { in: [true, false] }
  validates :share_phone_to_convict, inclusion: { in: [true, false] }

  before_validation :set_default_role

  scope :in_organization, ->(organization) { where(organization:) }

  pg_search_scope :search_by_name, against: %i[first_name last_name],
                                   using: {
                                     tsearch: { prefix: true }
                                   }

  delegate :name, to: :organization, prefix: true
  delegate :all_local_admins, to: :organization
  delegate :in_jurisdiction?, to: :organization

  def name(reverse: false)
    "#{last_name.upcase} #{first_name.capitalize}" unless reverse
    "#{first_name.capitalize} #{last_name.upcase}"
  end

  def identity
    return name unless phone.present?

    "#{name} - #{phone.phony_formatted.delete(' ')}"
  end

  def self.bex_roles
    %w[prosecutor greff_co dir_greff_bex bex greff_tpe greff_crpc greff_ca]
  end

  def self.sap_roles
    %w[jap secretary_court greff_sap dir_greff_sap]
  end

  def self.spip_roles
    %w[dpip cpip educator psychologist overseer secretary_spip]
  end

  def self.tj_roles
    sap_roles + bex_roles
  end

  def work_at_bex?
    User.bex_roles.include? role
  end

  def work_at_sap?
    User.sap_roles.include? role
  end

  def work_at_spip?
    return true if local_admin_spip?

    User.spip_roles.include? role
  end

  def local_admin_spip?
    local_admin? && organization.organization_type == 'spip'
  end

  def local_admin_tj?
    local_admin? && organization.organization_type == 'tj'
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

  private

  def set_default_role
    self.role ||= organization.organization_type == 'tj' ? 'greff_sap' : 'cpip'
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
end
