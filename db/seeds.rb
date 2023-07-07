ApplicationRecord.reset_column_information
Dir[Rails.root.join('db/seeds/*.rb')].sort.each do |file|
  puts "Processing #{file.split('/').last}"
  require file
end

org_tj_paris = Organization.find_or_create_by!(name: 'TJ Paris', organization_type: 'tj')

User.find_or_create_by!(
  organization: org_tj_paris, email: 'bextjparis@example.com', role: :bex, first_name: 'Stanislas', last_name: 'Wawrinka'
) do |user|
  user.password = '1mot2passeSecurise!'
  user.password_confirmation = '1mot2passeSecurise!'
end

User.find_or_create_by!(
  organization: org_tj_paris, email: 'admin@example.com', role: :admin, first_name: 'Kevin', last_name: 'McCallister'
) do |user|
  user.password = '1mot2passeSecurise!'
  user.password_confirmation = '1mot2passeSecurise!'
end






p 'Database seeded'
