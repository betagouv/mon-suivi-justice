require "csv"

desc "seed and invite agents"
task :invite_agents, [:filename] => [:environment] do |task, args|
  csv_data = Rails.root.join("lib", "seeds", "#{args[:filename]}.csv")
  CSV.foreach(csv_data, headers: true, col_sep: ",").with_index do |row, index|
    if User.find_by_email(row["EMAIL"]) || !Organization.find_by_name(row["ORGANIZATION"])
      Rails.logger.info("#{row["EMAIL"]} n'a pas pu être créé")
      puts "#{row["EMAIL"]} n'a pas pu être créé"
    else
      User.invite!(
        first_name: row["FIRST_NAME"],
        last_name: row["LAST_NAME"],
        role: row["ROLE"],
        email: row["EMAIL"],
        organization: Organization.find_by_name(row["ORGANIZATION"]),
      )
    end
  end
end
