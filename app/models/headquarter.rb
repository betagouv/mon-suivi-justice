class Headquarter < ApplicationRecord
  has_many :organizations, dependent: :nullify
  has_many :users, dependent: :nullify
  validates :name, presence: true

  delegate :local_admin, to: :users
  alias local_admins local_admin
end
