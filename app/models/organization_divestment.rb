class OrganizationDivestment < ApplicationRecord
  belongs_to :organization
  belongs_to :divestment
  delegate :convict, to: :divestment

  delegate :name, to: :organization, prefix: true
  delegate :name, to: :convict, prefix: true

  validates :comment, length: { maximum: 120 }, allow_blank: true

  scope :old_pending, lambda {
    joins(:divestment)
      .where('organization_divestments.created_at < ?', 10.days.ago)
      .where(organization_divestments: { state: 'pending' }, divestments: { state: 'pending' })
  }

  scope :reminders_due, lambda {
    where(state: 'pending')
      .where('last_reminder_email_at IS NULL OR last_reminder_email_at <= ?', 5.days.ago)
  }

  scope :unanswered, -> { where(state: %i[pending]) }
  scope :answered, -> { where(state: %i[ignored accepted auto_accepted refused]) }

  state_machine initial: :pending do
    event :accept do
      transition %i[pending ignored] => :accepted
    end

    event :auto_accept do
      transition pending: :auto_accepted
    end

    event :refuse do
      transition %i[pending ignored] => :refused
    end

    event :ignore do
      transition pending: :ignored
    end

    after_transition %i[pending ignored] => %i[accepted auto_accepted refused] do |organization_divestment, _transition|
      organization_divestment.update(decision_date: Time.zone.now)
    end
  end

  paginates_per 5

  delegate :name, to: :organization, prefix: true

  def source
    divestment.organization
  end

  def convict_name
    convict.full_name
  end

  def positively_answered?
    ignored? || accepted? || auto_accepted?
  end

  def answered?
    ignored? || accepted? || auto_accepted? || refused?
  end
end
