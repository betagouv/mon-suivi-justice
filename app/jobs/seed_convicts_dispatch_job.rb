class SeedConvictsDispatchJob < ApplicationJob
  #
  # Will rattach all convicts to all legal_areas(ie: departments + juridictions) of provided organizations
  #
  def perform(organization_ids)
    organizations = Organization.where id: organization_ids
    Convict.find_each { |convict| RegisterLegalAreas.for_convict(convict, from: organizations) }
  end
end
