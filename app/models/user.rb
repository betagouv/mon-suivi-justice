class User < ApplicationRecord
  include NormalizedPhone

  has_paper_trail

  CAN_INVITE_TO_CONVICT_INTERFACE =
    %w[charles.marcoin@beta.gouv.fr
       delphine.deneubourg@justice.fr
       melanie.plassais@justice.fr clement.roulet@justice.fr abel.diouf@justice.fr
       anne-sophie.genet@justice.fr anna.grinsnir@justice.fr pauline.guilloton@justice.fr
       claire.becanne@justice.fr].freeze

  belongs_to :organization
  has_many :convicts, dependent: :nullify
  has_many :appointments, dependent: :nullify
  has_many :visits, class_name: 'Ahoy::Visit'
  has_many :user_notifications, as: :recipient, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :timeoutable,
         :recoverable, :rememberable, :validatable, :password_has_required_content

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

  validates :first_name, :last_name, :role, presence: true
  validates :share_email_to_convict, inclusion: { in: [true, false] }
  validates :share_phone_to_convict, inclusion: { in: [true, false] }

  scope :in_department, lambda { |department|
    joins(organization: :areas_organizations_mappings)
      .where(areas_organizations_mappings: { area_type: 'Department', area_id: department.id })
  }

  scope :in_departments, lambda { |departments|
    ids = departments.map(&:id)
    joins(organization: :areas_organizations_mappings)
      .where(areas_organizations_mappings: { area_type: 'Department', area_id: ids })
  }

  scope :in_organization, ->(organization) { where(organization: organization) }

  delegate :name, to: :organization, prefix: true

  def name
    "#{last_name.upcase} #{first_name.capitalize}"
  end

  def identity
    return name unless phone.present?

    "#{name} - #{phone.phony_formatted.delete(' ')}"
  end

  def work_at_bex?
    %w[prosecutor greff_co dir_greff_bex bex greff_tpe greff_crpc greff_ca].include? role
  end

  def work_at_sap?
    %w[jap secretary_court greff_sap dir_greff_sap].include? role
  end

  def work_at_spip?
    %w[dpip cpip educator psychologist overseer secretary_spip].include? role
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
    [organization, *organization.linked_or_associated_organization]
  end
end
