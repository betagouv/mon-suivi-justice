# rails r scripts/change_versions_type.rb

require 'ruby-progressbar'
# voir https://github.com/paper-trail-gem/paper_trail/issues/1394
::YAML.load_tags['!ruby/object:ActiveRecord::Type::Time::Value'] = 'ActiveSupport::TimeWithZone'
versions = PaperTrail::Version.where.not(old_object: nil, old_object_changes: nil)
p versions.count
progress = ProgressBar.create(total: versions.count)

versions.each do |version|
  p "Handling version id: #{version.id}"
  begin
    version.update_columns old_object: nil, object: YAML.safe_load(version.old_object, permitted_classes: Rails.application.config.active_record.yaml_column_permitted_classes, aliases: true) if version.old_object.present?
    if version.old_object_changes.present?
      old_object_changes = YAML.safe_load(version.old_object_changes, permitted_classes: Rails.application.config.active_record.yaml_column_permitted_classes, aliases: true)
      version.update_columns old_object_changes: nil, object_changes: old_object_changes
    end
    progress.increment
  rescue => e
    p "Error: #{e.message}"
    next
  end
end

p "PaperTrail::Version old_object and old_object_changes updated to jsonb type."
