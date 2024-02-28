# rake change_versions_type\[1,1000000\]
# with id1 the id of the organization source, id2 the organization to import into
#

desc 'Change versions type from yaml to jsonb.'
task :change_versions_type, %i[start finish] => [:environment] do |_task, args|
  YAML.load_tags['!ruby/object:ActiveRecord::Type::Time::Value'] = 'ActiveSupport::TimeWithZone'
  versions = PaperTrail::Version.where.not(old_object: nil, old_object_changes: nil)
  permitted_classes = Rails.application.config.active_record.yaml_column_permitted_classes

  versions.find_each(batch_size: 100_000, start: args[:start], finish: args[:finish]) do |version|
    process_version(version, permitted_classes)
  end
end

def process_version(version, permitted_classes)
  p "Processing version id #{version.id}"
  if version.old_object.present?
    old_object = process_old_object(version, permitted_classes)
    version.update_columns old_object: nil, object: old_object
  end
  if version.old_object_changes.present?
    old_object_changes = process_old_object_changes(version, permitted_classes)
    version.update_columns old_object_changes: nil, object_changes: old_object_changes
  end
rescue StandardError => e
  p "Error: #{e.message}"
end

def process_old_object(version, permitted_classes)
  old_object = version.old_object
  if version.old_object.include?('!ruby/object:ActiveRecord::Type::Time::Value')
    old_object = version.old_object.gsub('  ', '')
                        .gsub('!ruby/object:ActiveRecord::Type::Time::Value',
                              'Sat, 01 Jan 2000 05:00:00.000000000 UTC +00:00')
  end
  YAML.safe_load(old_object, permitted_classes:, aliases: true)
end

def process_old_object_changes(version, permitted_classes)
  old_object_change = version.old_object_changes
  if version.old_object_change.include?('!ruby/object:ActiveRecord::Type::Time::Value')
    old_object_change = version.old_object_change.gsub('  ', '')
                               .gsub('!ruby/object:ActiveRecord::Type::Time::Value',
                                     'Sat, 01 Jan 2000 05:00:00.000000000 UTC +00:00')
  end
  YAML.safe_load(old_object_change, permitted_classes:, aliases: true)
end
