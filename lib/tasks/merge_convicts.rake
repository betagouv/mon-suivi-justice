# rake merge_convicts[id1,id2]
# with id1 the id of the convict to keep, id2 the convict to merge
# ex : rake merge_convicts\[10,11\]
# the \ are for zsh, source : https://www.seancdavis.com/posts/4-ways-to-pass-arguments-to-a-rake-task

desc 'merge duplicated convicts'
task :merge_convicts, %i[id1 id2] => [:environment] do |_task, args|
  kept_convict = Convict.find(args[:id1])
  duplicated_convict = Convict.find(args[:id2])

  ActiveRecord::Base.transaction do
    duplicated_convict.appointments.update_all(convict_id: kept_convict.id)
    duplicated_convict.history_items.update_all(convict_id: kept_convict.id)

    kept_convict.save!
    duplicated_convict.destroy!
  end
end
