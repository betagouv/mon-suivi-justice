class User < ApplicationRecord
  include NormalizedPhone
  include PgSearch::Model

  has_paper_trail

  CAN_INVITE_TO_CONVICT_INTERFACE =
    %w[charles.marcoin@beta.gouv.fr
       delphine.deneubourg@justice.fr
       melanie.plassais@justice.fr clement.roulet@justice.fr abel.diouf@justice.fr
       anne-sophie.genet@justice.fr anna.grinsnir@justice.fr pauline.guilloton@justice.fr
       claire.becanne@justice.fr].freeze

  belongs_to :organization
  belongs_to :headquarter, optional: true
  has_many :convicts, dependent: :nullify
  has_many :appointments, dependent: :nullify
  has_many :invited_appointments, class_name: 'Appointment', foreign_key: :inviter_user_id, dependent: :nullify
  has_many :visits, class_name: 'Ahoy::Visit'
  has_many :user_notifications, as: :recipient, dependent: :destroy
  has_many :user_user_alerts, dependent: :destroy
  has_many :user_alerts, through: :user_user_alerts
  has_many :unread_user_alerts, -> { where(user_user_alerts: { read_at: nil }) },
           through: :user_user_alerts, source: :user_alert

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

  after_create_commit { CreateContactInBrevoJob.perform_now(id) }
  after_update_commit { UpdateContactInBrevoJob.perform_later(id) }

  validates :first_name, :last_name, presence: true
  validates :share_email_to_convict, inclusion: { in: [true, false] }
  validates :share_phone_to_convict, inclusion: { in: [true, false] }

  before_validation :set_default_role

  scope :in_department, lambda { |department|
    joins(organization: :areas_organizations_mappings)
      .where(areas_organizations_mappings: { area_type: 'Department', area_id: department.id })
  }

  scope :in_organization, ->(organization) { where(organization:) }

  pg_search_scope :search_by_name, against: %i[first_name last_name],
                                   using: {
                                     tsearch: { prefix: true }
                                   }

  delegate :name, to: :organization, prefix: true

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

  def can_invite_to_convict_interface?
    CAN_INVITE_TO_CONVICT_INTERFACE.include?(email) || admin?
  end

  def can_have_appointments_assigned?
    %w[cpip psychologist overseer].include? role
  end

  def organizations
    [organization, *organization.linked_organizations]
  end

  def can_use_inter_ressort?
    work_at_bex? && organization.use_inter_ressort?
  end

  private

  def set_default_role
    self.role ||= organization.organization_type == 'tj' ? 'greff_sap' : 'cpip'
  end
end
