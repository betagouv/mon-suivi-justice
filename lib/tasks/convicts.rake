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
end
