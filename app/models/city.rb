class City < ApplicationRecord
  include PgSearch::Model

  belongs_to :srj_spip, optional: true
  belongs_to :srj_tj, optional: true

  has_many :convicts, dependent: :nullify

  has_one :spip_organization, through: :srj_spip, source: :organization
  has_one :tj_organization, through: :srj_tj, source: :organization

  scope :with_at_least_one_tj, -> { joins(:srj_tj).where('srj_tjs.organization_id IS NOT NULL') }
  scope :with_at_least_one_spip, -> { joins(:srj_spip).where('srj_spips.organization_id IS NOT NULL') }
  scope :with_at_least_one_service, -> { (with_at_least_one_tj + with_at_least_one_spip).uniq }

  pg_search_scope :search_by_name, against: %i[name],
                                   using: {
                                     tsearch: { prefix: true }
                                   }

  def organizations
    [srj_tj&.organization, srj_spip&.organization].compact
  end
end
