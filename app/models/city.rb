class City < ApplicationRecord
  belongs_to :srj_spip
  belongs_to :srj_tj

  scope :with_at_least_one_tj, -> { joins(:srj_tj).where('srj_tjs.organization_id IS NOT NULL') }
  scope :with_at_least_one_spip, -> { joins(:srj_spip).where('srj_spips.organization_id IS NOT NULL') }
  scope :with_at_least_one_service, -> { (with_at_least_one_tj + with_at_least_one_spip).uniq }
end
