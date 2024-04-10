class Divestment < ApplicationRecord
  belongs_to :user
  belongs_to :convict
  belongs_to :organization

  has_many :organization_divestments, dependent: :destroy
  has_many :involved_organizations, through: :organization_divestments, source: :organization

  validates :convict_id, uniqueness: { scope: :state,
                                       message: 'le probationnaire a déjà une demande de dessaisissement en cours' },
                         if: -> { state == 'pending' }

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

    after_transition pending: any do |divestment, transition|
      divestment.update(decision_date: Time.zone.now)
      event = "#{divestment.event_name(transition.event)}_divestment"
      p event
      if HistoryItem.validate_event(event) == true
        HistoryItemFactory.perform(
          convict:,
          event:,
          category: 'convict',
          data: { target_name: organization.name }
        )
      end
    end
  end

  def event_name(transition_event)
    case transition_event
    when :auto_accept
      :accept
    else
      transition_event
    end
  end

  def all_accepted?
    organization_divestments.all?(&:is_accepted?)
  end
end
