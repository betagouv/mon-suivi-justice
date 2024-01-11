class Divestment < ApplicationRecord
  belongs_to :user
  belongs_to :convict
  has_many :organization_divestments
  has_many :organizations, through: :organization_divestments

  state_machine initial: :pending do
    event :accept do
      transition pending: :accepted
    end

    event :refuse do
      transition pending: :refused
    end
  end
end
