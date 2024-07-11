class Divestment < ApplicationRecord
  belongs_to :user
  belongs_to :convict
  belongs_to :organization

  has_many :organization_divestments, dependent: :destroy
  has_many :involved_organizations, through: :organization_divestments, source: :organization

  validates :convict_id, uniqueness: { scope: :state,
                                       message: 'le probationnaire a déjà une demande de dessaisissement en cours' },
                         if: -> { state == 'pending' }
  validate :convict_is_not_japat, on: :create

  scope :admin_action_needed, -> { where(state: :pending, created_at: ..10.days.ago) }
  delegate :jurisdiction, to: :organization, prefix: true

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

    after_transition pending: %i[accepted auto_accepted refused] do |divestment, transition|
      divestment.update(decision_date: Time.zone.now)
      divestment.record_history_for_transition(transition.event == :refuse ? :refuse : :accept)
    end
  end

  delegate :name, to: :organization, prefix: true

  paginates_per 5

  def all_accepted?
    organization_divestments.all?(&:positively_answered?)
  end

  def record_history_for_transition(transition_event)
    event = "#{transition_event}_divestment"
    return unless HistoryItem.validate_event(event)

    HistoryItemFactory.perform(
      convict:,
      event:,
      category: 'convict',
      data: { divestment: self }
    )
  end

  def convict_is_not_japat
    return unless convict.japat?

    errors.add(:convict,
               'Code 12 - Dessaisissment impossible pour ce probationnaire, veuillez contacter un administrateur.')
  end

  def source_use_ir?
    involved_organizations.any?(&:use_inter_ressort?)
  end

  def target_use_ir?
    organization_jurisdiction.any?(&:use_inter_ressort?)
  end
end
