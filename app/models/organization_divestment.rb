class OrganizationDivestment < ApplicationRecord
  belongs_to :organization
  belongs_to :divestment
  delegate :convict, to: :divestment

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

    after_transition pending: any do |divestment|
      divestment.update(decision_date: Time.zone.now)
    end
  end

  validates :comment, length: { maximum: 120 }, allow_blank: true

  def source
    divestment.organization
  end

  def other_organizations_divestments
    divestment.organization_divestments.where.not(id:)
  end

  def orga_name
    organization.name
  end

  def convict_name
    convict.full_name
  end

  def is_accepted?
    # should ignored be considered as accepted?
    accepted? || auto_accepted?
  end
end
