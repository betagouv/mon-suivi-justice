class OrganizationDivestment < ApplicationRecord
  belongs_to :organization
  belongs_to :divestment
  delegate :convict, to: :divestment

  delegate :name, to: :organization, prefix: true
  delegate :name, to: :convict, prefix: true

  scope :old_pending, lambda {
    joins(:divestment)
      .where('organization_divestments.created_at < ?', 10.days.ago)
      .where(organization_divestments: { state: 'pending' }, divestments: { state: 'pending' })
  }

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

    after_transition pending: any do |organization_divestment|
      organization_divestment.update(decision_date: Time.zone.now)
    end
  end

  validates :comment, length: { maximum: 120 }, allow_blank: true

  def source
    divestment.organization
  end

  def other_organizations_divestments
    divestment.organization_divestments.where.not(id:)
  end

  def convict_name
    convict.full_name
  end

  # rubocop:disable Naming/PredicateName
  def is_accepted?
    accepted? || auto_accepted? || ignored?
  end
  # rubocop:enable Naming/PredicateName
end
