class City < ApplicationRecord
  belongs_to :spip
  belongs_to :tj

  scope :with_at_least_one_tj, -> { joins(:tj).where('tjs.organization_id IS NOT NULL') }
  scope :with_at_least_one_spip, -> { joins(:spip).where('spips.organization_id IS NOT NULL') }
  scope :with_at_least_one_service, -> { (with_at_least_one_tj + with_at_least_one_spip).uniq }
end
