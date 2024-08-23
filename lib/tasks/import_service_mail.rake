desc 'add service mail to organization'
task :import_service_mail, [:filepath] => [:environment] do |_task, args|
  csv_data = args[:filepath]

  CSV.foreach(csv_data, headers: true, col_sep: ',').with_index do |row, _index|
    service = Organization.where('lower(name) = ?', row['NAME'].downcase).first

    if service.blank?
      puts "Service not found: #{row['NAME']}"
      next
    end

    service.update(email: row['MAIL']) if service.mail.blank?
  end
end
