ApplicationRecord.reset_column_information
Dir[Rails.root.join('db/seeds/*.rb')].sort.each do |file|
  puts "Processing #{file.split('/').last}"
  require file
end

org_tj_paris = Organization.find_or_create_by!(name: 'TJ Paris', organization_type: 'tj')
create_user(organization: org_tj_paris, email: 'bextjparis@example.com', role: :bex)

create_admin(email: 'matthieu.faugere@beta.gouv.fr', first_name: 'Matthieu', last_name: 'Faugère')
create_admin(email: 'camille.teulier@beta.gouv.fr', first_name: 'Camille', last_name: 'Teulier')
create_admin(email: 'damien.le-thiec@beta.gouv.fr', first_name: 'Damien', last_name: 'Le Thiec')
create_admin(email: 'clelia.virlogeux@beta.gouv.fr', first_name: 'Clélia', last_name: 'Virlogeux')
create_admin(email: 'cyril.ache@beta.gouv.fr', first_name: 'Cyril', last_name: 'Ache')
create_admin(email: 'virginie.collignon-ducret@beta.gouv.fr', first_name: 'Virginie', last_name: 'Collignon-Ducret')
create_admin(email: 'stephanie.langlais@justice.fr', first_name: 'Stéphanie', last_name: 'Langlais')
create_admin(email: 'cyrille.corbin@justice.gouv.fr', first_name: 'Cyrille', last_name: 'Corbin')

p 'Database seeded'
