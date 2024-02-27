# lib/tasks/change_versions_type.rake

desc 'Change versions type from yaml to jsonb.'
task change_versions_type: :environment do
  require 'ruby-progressbar'
  YAML.load_tags['!ruby/object:ActiveRecord::Type::Time::Value'] = 'ActiveSupport::TimeWithZone'
  versions = PaperTrail::Version.where.not(old_object: nil, old_object_changes: nil)
  p versions.count
  progress = ProgressBar.create(total: versions.count)
  permitted_classes = Rails.application.config.active_record.yaml_column_permitted_classes

  versions.each do |version|
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

  p 'PaperTrail::Version old_object and old_object_changes updated to jsonb type.'
end
