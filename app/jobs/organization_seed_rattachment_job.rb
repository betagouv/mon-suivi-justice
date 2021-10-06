class OrganizationSeedRattachmentJob < ApplicationJob
  def perform
    #
    # Job to be run to seed first Organization and rattach user/place to it
    # Can be deleted after the deployment
    #
    organization = Organization.find_or_create_by name: 'SPIP 92'
    return unless organization

    User.update_all  organization_id: organization.id
    Place.update_all organization_id: organization.id
  end
end
