require 'rails_helper'

RSpec.describe 'Import Srjs', type: :feature, logged_in_as: 'admin' do
  it 'creates a city and associates it with the srj service described in the csv' do
    visit admin_import_srjs_path

    expect(page).to have_content('Import des villes et de leur relation avec les services au sens SRJ (.csv)')

    attach_file('srj_file', Rails.root.join('spec/fixtures/valid_srjs.csv'))

    click_button 'Importer'

    expect(page).to have_content('Import SRJ en cours ! Vous recevrez le rapport par mail dans quelques minutes')

    perform_enqueued_jobs

    city = City.find_by(name: 'Ville')
    expect(city).not_to be_nil
    expect(city.srj_spip.name).to eq('SPIP de Ville')
  end

  it 'rejects a file whose content is not a valid csv, even with a .csv extension' do
    visit admin_import_srjs_path

    attach_file('srj_file', Rails.root.join('spec/fixtures/binary_disguised_as.csv'))

    click_button 'Importer'

    expect(page).to have_content('Erreur : Le contenu du fichier ne correspond pas à un CSV valide')
    expect(City.count).to eq(0)
  end

  it 'rejects a file that is not a .csv' do
    visit admin_import_srjs_path

    attach_file('srj_file', Rails.root.join('spec/fixtures/valid_convicts.txt'))

    click_button 'Importer'

    expect(page).to have_content('Erreur : Seul le format csv est supporté')
    expect(City.count).to eq(0)
  end
end
