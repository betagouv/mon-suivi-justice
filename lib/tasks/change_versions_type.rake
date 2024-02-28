# change_versions_type\[1,1000000\]
# with id1 the id of the organization source, id2 the organization to import into

require 'ruby-progressbar'

desc 'Change versions type from yaml to jsonb.'
task :change_versions_type, %i[start finish] => [:environment] do |_task, args|
  YAML.load_tags['!ruby/object:ActiveRecord::Type::Time::Value'] = 'ActiveSupport::TimeWithZone'
  versions = PaperTrail::Version.where.not(old_object: nil, old_object_changes: nil)
  permitted_classes = Rails.application.config.active_record.yaml_column_permitted_classes

  versions.find_each(batch_size: 100_000, start: args[:start], finish: args[:finish]) do |version|
    progress = ProgressBar.create(total: 100_000)
    p "Processing version id #{version.id}"
    if version.old_object.present?
      old_object = YAML.safe_load(version.old_object, permitted_classes:, aliases: true)
      version.update_columns old_object: nil, object: old_object
    end
    if version.old_object_changes.present?
      old_object_changes = YAML.safe_load(version.old_object_changes,
                                          permitted_classes:, aliases: true)
      version.update_columns old_object_changes: nil, object_changes: old_object_changes
    end
    progress.increment
  rescue StandardError => e
    p "Error: #{e.message}"
    next
  end
end
