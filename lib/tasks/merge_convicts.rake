# Before merging, copy in console to the convict to keep the attributes you want to conserve from the convict to merge
# (appi_uuid, phone, date_of_birth, etc.).
# If you cannot save because of uniqueness constraint, you can use `convict.save(validate: false)` here.
# rake merge_convicts[id1,id2]
# with id1 the id of the convict to keep, id2 the convict to merge
# ex : rake merge_convicts\[10,11\]
# the \ are for zsh, source : https://www.seancdavis.com/posts/4-ways-to-pass-arguments-to-a-rake-task
# In production : scalingo --app mon-suivi-justice-prod --region osc-secnum-fr1 run rake merge_convicts\[id1,id2\]

desc 'merge duplicated convicts'
task :merge_convicts, %i[id1 id2] => [:environment] do |_task, args|
  kept_convict = Convict.find(args[:id1])
  duplicated_convict = Convict.find(args[:id2])

  ActiveRecord::Base.transaction do
    duplicated_convict.appointments.update_all(convict_id: kept_convict.id)
    duplicated_convict.history_items.update_all(convict_id: kept_convict.id)

    kept_convict.save!(validate: false)
    duplicated_convict.destroy!
  end
end
