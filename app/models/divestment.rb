class Divestment < ApplicationRecord
  belongs_to :user
  belongs_to :organization_from, class_name: 'Organization'
  belongs_to :organization_to, class_name: 'Organization'

  state_machine initial: :pending do
    event :accept do
      transition pending: :accepted
    end

    event :refuse do
      transition pending: :refused
    end
  end
end
