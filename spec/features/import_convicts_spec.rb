require 'rails_helper'

RSpec.describe 'Import Convicts', type: :feature, logged_in_as: 'admin' do
  before do
    @organization = create(:organization)
    @organization2 = create(:organization, organization_type: 'tj', spips: [@organization])
  end

  it 'create convicts in proper organizations' do
    visit admin_import_convicts_path

    expect(page).to have_content('Ajout des probationnaires de APPI (.csv) dans un service MSJ')

    select @organization.name, from: 'organization_id'

    attach_file('convicts_list', Rails.root.join('spec/fixtures/valid_convicts.csv'))

    click_button 'Créer'

    expect(page).to have_content('Import en cours ! Vous recevrez le rapport par mail dans quelques minutes')

    # Using Sidekiq::Testing.inline to perform the job immediately
    perform_enqueued_jobs

    new_convict = Convict.find_by(first_name: 'Bob', last_name: 'DUPNEU', date_of_birth: '15/11/1993'.to_date,
                                  appi_uuid: '201111111111')

    # Check if there is only on convict with the same first_name, last_name and date_of_birth
    expect(Convict.where(first_name: 'John', last_name: 'DOE', date_of_birth: '02/02/1986'.to_date).count).to eq(1)
    # expect new_convict organizations to include @organization and @organization2
    expect(new_convict.organizations).to include(@organization)
    expect(new_convict.organizations).to include(@organization2)

    expect(new_convict).not_to be_nil
  end

  it 'updates existing convicts' do
    convict = create(:convict, first_name: 'Bob', last_name: 'DUPNEU', date_of_birth: '15/11/1993'.to_date,
                               appi_uuid: '201111111111', organizations: [@organization])

    visit admin_import_convicts_path

    select @organization2.name, from: 'organization_id'

    attach_file('convicts_list', Rails.root.join('spec/fixtures/valid_convicts.csv'))

    click_button 'Créer'

    # Using Sidekiq::Testing.inline to perform the job immediately
    perform_enqueued_jobs

    expect(convict.organizations).to include(@organization)
  end

  it 'only creates convict in selected organization if it has two ore more associated organizations' do
    @organization3 = create(:organization, organization_type: 'spip')
    @organization4 = create(:organization, organization_type: 'tj', spips: [@organization, @organization3])

    visit admin_import_convicts_path

    select @organization4.name, from: 'organization_id'

    attach_file('convicts_list', Rails.root.join('spec/fixtures/valid_convicts.csv'))

    click_button 'Créer'

    # Using Sidekiq::Testing.inline to perform the job immediately
    perform_enqueued_jobs

    expect(Convict.count).to eq(3)
    expect(Convict.last.organizations).to include(@organization4)
  end
end
