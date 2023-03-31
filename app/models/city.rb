class City < ApplicationRecord
  belongs_to :srj_spip, optional: true
  belongs_to :srj_tj, optional: true

  has_many :convicts, dependent: :nullify

  scope :with_at_least_one_tj, -> { joins(:srj_tj).where('srj_tjs.organization_id IS NOT NULL') }
  scope :with_at_least_one_spip, -> { joins(:srj_spip).where('srj_spips.organization_id IS NOT NULL') }
  scope :with_at_least_one_service, -> { (with_at_least_one_tj + with_at_least_one_spip).uniq }

  def organizations
    [srj_tj&.organization, srj_spip&.organization]
  end
end
