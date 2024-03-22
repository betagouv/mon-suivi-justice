class OrganizationDivestment < ApplicationRecord
  belongs_to :organization
  belongs_to :divestment

  state_machine initial: :pending do
    event :accept do
      transition pending: :accepted
    end

    event :auto_accept do
      transition pending: :auto_accepted
    end

    event :refuse do
      transition pending: :refused
    end

    event :ignore do
      transition pending: :ignored
    end
  end

  validates :comment, length: { maximum: 120 }, allow_blank: true
end
