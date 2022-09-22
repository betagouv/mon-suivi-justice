# $ rake invite_agents -- --filepath /path/from/container/root.csv
require 'csv'

desc 'seed and invite agents'
task :invite_agents, [:filepath] => [:environment] do |_task, args|
  CSV.foreach(args[:filepath], headers: true, col_sep: ',').with_index do |row, _index|
    if User.find_by_email(row['EMAIL']) || !Organization.find_by_name(row['ORGANIZATION'])
      Rails.logger.info("#{row['EMAIL']} n'a pas pu être créé")
      puts "#{row['EMAIL']} n'a pas pu être créé"
    else
      User.invite!(
        first_name: row['FIRST_NAME'],
        last_name: row['LAST_NAME'],
        phone: row['PHONE'].nil? ? '' : row['PHONE'],
        role: row['ROLE'],
        email: row['EMAIL'],
        organization: Organization.find_by_name(row['ORGANIZATION'])
      )
    end
  end
end
