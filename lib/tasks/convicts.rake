namespace :convicts do
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
