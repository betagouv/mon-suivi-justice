class LinkConvictFromOrganizationsSourceJob < ApplicationJob
  require 'csv'
  queue_as :default

  def perform(organization, user, organizations_source)
    @import_errors = []
    @import_successes = []

    link_convicts(organization, user, organizations_source)
  rescue StandardError => e
    @import_errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user: user, organization: organization, import_errors: @import_errors,
                     import_successes: @import_successes,
                     sources: organizations_source.pluck(:name)).link_convict_from_organizations_source.deliver_later
  end

  def link_convicts(organization, user, organizations_source)
    organizations_source.each do |source|
      source.convicts.each do |convict|
        next if convict.organizations.include?(organization)

        convict.current_user = user
        link_convict(convict, organization)
      end
    end
  end

  def link_convict(convict, organization)
    convict.organizations.push(organization)

    if convict.save
      @import_successes.push("(id: #{convict.id})")
    else
      @import_errors.push("(id: #{convict.id}) - #{convict.errors.full_messages.first}")
    end
  end
end
