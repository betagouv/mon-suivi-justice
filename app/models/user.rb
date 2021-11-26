class User < ApplicationRecord
  has_paper_trail

  belongs_to :organization

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :timeoutable,
         :recoverable, :rememberable, :validatable, :password_has_required_content

  enum role: {
    admin: 0,
    bex: 1,
    cpip: 2,
    sap: 3,
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
    secretary_spip: 16
  }

  validates :first_name, :last_name, :role, presence: true

  scope :in_department, lambda { |department|
    joins(organization: :areas_organizations_mappings)
      .where(areas_organizations_mappings: { area_type: 'Department', area_id: department.id })
  }

  def name
    "#{last_name.upcase} #{first_name.capitalize}"
  end

  def work_at_bex?
    %w[prosecutor greff_co dir_greff_bex bex].include? role
  end

  def work_at_sap?
    %w[jap secretary_court greff_sap dir_greff_sap sap].include? role
  end

  def work_at_spip?
    %w[dpip cpip educator psychologist overseer secretary_spip].include? role
  end
end
