# rake merge_convicts[id1,id2]
# with id1 the id of the convict to keep, id2 the convict to merge
# ex : rake merge_convicts\[10,11\]
# the \ are for zsh, source : https://www.seancdavis.com/posts/4-ways-to-pass-arguments-to-a-rake-task

desc 'merge duplicated convicts'
task :merge_convicts, [:id1, :id2] => [:environment] do |task, args|
  kept_convict = Convict.find(args[:id1])
  duplicated_convict = Convict.find(args[:id2])

  duplicated_convict.appointments.each do |a|
    a.convict_id = kept_convict.id
    a.save!
  end

  duplicated_convict.history_items.each do |hi|
    hi.convict_id = kept_convict.id
    hi.save!
  end

  kept_convict.save!
  duplicated_convict.destroy!
end
