class User < ApplicationRecord
  has_paper_trail

  belongs_to :organization

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :timeoutable,
         :recoverable, :rememberable, :validatable

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

  def name
    "#{last_name.upcase} #{first_name.capitalize}"
  end
end
