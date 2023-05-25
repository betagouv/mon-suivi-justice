namespace :convicts do
  desc 'Link all convicts to their organizations'
  task link_to_organization: :environment do
    convict_migration_errors = []
    convict_migration_success = 0
    Convict.all.each do |convict|
      next if convict.organizations.present?

      departments = convict.departments
      jurisdictions = convict.jurisdictions
      dpt_orga = departments.flat_map(&:organizations).uniq
      jdt_orga = jurisdictions.flat_map(&:organizations).uniq

      organizations = [*dpt_orga, *jdt_orga].uniq
      p "Convict #{convict.id} is linked to #{organizations.map(&:id)}"
      next unless organizations.present?

      convict.organizations = organizations
      convict.save!
      convict_migration_success += 1
    rescue StandardError => e
      convict_migration_errors.push("Erreur : #{e.message} pour le convict #{convict.id}")
    end

    AdminMailer.with(convict_migration_errors: convict_migration_errors,
                     convict_migration_success: convict_migration_success).convict_migration_report.deliver_later
  end
  desc 'link convict from other organization'
  # rake convicts:link_from_other_organization[id1,id2]
  # with id1 the id of the organization source, id2 the organization to import into
  # ex : convicts:link_from_other_organization\[10,11\]
  # the \ are for zsh, source : https://www.seancdavis.com/posts/4-ways-to-pass-arguments-to-a-rake-task
  task :link_from_other_organization, %i[id1 id2] => [:environment] do |_task, args|
    organization_source = Organization.find(args[:id1])
    organization_target = Organization.find(args[:id2])

    ActiveRecord::Base.transaction do
      organization_source.convicts.each do |convict|
        convict.organizations.push(organization_target) if convict.organizations.exclude?(organization_target)
        convict.save(validate: false)
      end
    end
  end
end
