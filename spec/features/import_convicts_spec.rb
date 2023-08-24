require 'rails_helper'

RSpec.describe 'Import Convicts', type: :feature, logged_in_as: 'admin' do
  before do
    # Assuming you have a factory for Organization and Headquarter
    @organization = create(:organization)
    @headquarter = create(:headquarter)
  end

  it 'submits the form and imports convicts' do
    visit admin_import_convicts_path

    expect(page).to have_content('Ajout des probationnaires de APPI (.csv) dans un service MSJ')

    select @organization.name, from: 'organization_id'

    attach_file('convicts_list', Rails.root.join('spec/fixtures/valid_convicts.csv'))

    click_button 'Créer'

    expect(page).to have_content('Import en cours ! Vous recevrez le rapport par mail dans quelques minutes')

    # Using Sidekiq::Testing.inline to perform the job immediately
    perform_enqueued_jobs

    new_convict = Convict.find_by(first_name: 'Bob', last_name: 'DUPNEU', date_of_birth: '15/11/1993'.to_date)
    expect(new_convict).not_to be_nil
    expect(new_convict.organizations).to include(@organization)
  end
end
