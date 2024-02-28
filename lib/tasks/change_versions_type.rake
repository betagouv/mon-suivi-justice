# rake change_versions_type\[1,1000000\]
# with id1 the id of the organization source, id2 the organization to import into

require 'ruby-progressbar'

desc 'Change versions type from yaml to jsonb.'
task :change_versions_type, %i[start finish] => [:environment] do |_task, args|
  YAML.load_tags['!ruby/object:ActiveRecord::Type::Time::Value'] = 'ActiveSupport::TimeWithZone'
  versions = PaperTrail::Version.where.not(old_object: nil, old_object_changes: nil)
  permitted_classes = Rails.application.config.active_record.yaml_column_permitted_classes

  versions.find_each(batch_size: 100_000, start: args[:start], finish: args[:finish]) do |version|
    p "Processing version id #{version.id}"
    if version.old_object.present?
      modified_old_object = version.old_object.gsub('  ', '')
                                   .gsub('!ruby/object:ActiveRecord::Type::Time::Value',
                                         'Sat, 01 Jan 2000 05:00:00.000000000 UTC +00:00')
      old_object = YAML.safe_load(modified_old_object, permitted_classes:, aliases: true)
      version.update_columns old_object: nil, object: old_object
    end
    if version.old_object_changes.present?
      modified_old_object_changes = version.old_object_changes.gsub('  ', '')
                                           .gsub('!ruby/object:ActiveRecord::Type::Time::Value',
                                                 'Sat, 01 Jan 2000 05:00:00.000000000 UTC +00:00')
      old_object_changes = YAML.safe_load(modified_old_object_changes, permitted_classes:, aliases: true)
      version.update_columns old_object_changes: nil, object_changes: old_object_changes
    end
  rescue StandardError => e
    p "Error: #{e.message}"
    next
  end
end
