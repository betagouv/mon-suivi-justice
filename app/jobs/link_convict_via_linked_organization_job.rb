class LinkConvictViaLinkedOrganizationJob < ApplicationJob
  require 'csv'
  queue_as :default

  def perform(organization, user)
    @import_errors = []
    @import_successes = []

    link_convicts(organization)
  rescue StandardError => e
    @import_errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user: user, organization: organization, import_errors: @import_errors,
                     import_successes: @import_successes).link_convict_from_linked_orga.deliver_later
  end

  def link_convicts(organization)
    linked_organizations = organization.linked_organizations
    linked_organizations.each do |linked_organization|
      linked_organization.convicts.each do |convict|
        next if convict.organizations.include?(organization)

        link_convict(convict, organization)
      end
    end
  end

  def link_convict(convict, organization)
    convict.organizations.push(organization)
    if convict.save
      @import_successes.push("#{convict.first_name} (id: #{convict.id})")
    else
      @import_errors.push("#{convict.first_name} - #{convict.errors.full_messages.first}")
    end
  end
end
