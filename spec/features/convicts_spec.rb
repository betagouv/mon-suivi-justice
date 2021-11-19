require 'rails_helper'

RSpec.feature 'Convicts', type: :feature do
  before do
    create_admin_user_and_login
  end

  describe 'index' do
    before do
      create(:convict, first_name: 'michel', phone: '0607080910')
      create(:convict, first_name: 'Paul')
      visit convicts_path
    end

    it 'an admin lists all convicts' do
      expect(page).to have_content('Michel')
      expect(page).to have_content('06 07 08 09 10')
      expect(page).to have_content('Paul')
    end

    it 'an admin can delete convict' do
      within first('.convicts-item-container') do
        expect { click_link('Supprimer') }.to change { Convict.count }.by(-1)
      end
    end

    it 'an agent see only convict from his jurisdiction and department' do
      dpt01 = create :department, number: '01', name: 'Ain'
      juri01 = create :jurisdiction, name: 'jurisdiction_01'
      orga = create :organization
      user = create :user, role: 'cpip', organization: orga
      create :areas_organizations_mapping, organization: orga, area: dpt01
      create :areas_organizations_mapping, organization: orga, area: juri01
      create :user, organization: orga
      convict_dpt01 = create :convict, first_name: 'babar', last_name: 'BABAR'
      convict_juri01 = create :convict, first_name: 'bobor', last_name: 'BOBOR'
      create :areas_convicts_mapping, convict: convict_dpt01, area: dpt01
      create :areas_convicts_mapping, convict: convict_juri01, area: juri01
      logout_current_user
      login_user user
      visit convicts_path
      expect(page).not_to have_content('Michel')
      expect(page).not_to have_content('Paul')
      expect(page).to have_content('BABAR Babar')
      expect(page).to have_content('BOBOR Bobor')
    end
  end

  describe 'creation' do
    it 'creates a convicts with a phone number' do
      visit new_convict_path

      select 'M.', from: 'Civilité'
      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'

      expect { click_button 'submit-no-appointment' }.to change { Convict.count }.by(1)
    end

    it 'creates a convicts with a duplicate name' do
      visit new_convict_path

      select 'M.', from: 'Civilité'
      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'

      expect { click_button 'submit-no-appointment' }.to change { Convict.count }.by(1)
    end

    it 'allows to create a convict without a phone number' do
      create(:convict, first_name: 'roberta', last_name: 'dupond')
      visit new_convict_path

      select 'M.', from: 'Civilité'
      fill_in 'Prénom', with: 'Roberta'
      fill_in 'Nom', with: 'Dupond'
      fill_in 'Téléphone', with: '0606060606'
      expect { click_button('submit-no-appointment') }.not_to change(Convict, :count)
      expect(page).to have_content(
        'Une PPSMJ existe déjà avec ce nom et prénom. Êtes-vous sur(e) de vouloir continuer ?'
      )
      expect { click_button('submit-no-appointment') }.to change(Convict, :count).by(1)
    end

    it 'creates a convict with his first appointment', js: true do
      appointment_type = create(:appointment_type, :with_notification_types, name: 'Premier contact Spip')
      place = create(:place, name: 'McDo de Clichy', appointment_types: [appointment_type])
      agenda = create(:agenda, place: place, name: 'Agenda de Jean-Louis')

      create(:agenda, place: place, name: 'Agenda de Michel')
      create(:slot, agenda: agenda,
                    appointment_type: appointment_type,
                    date: (Date.today + 2).to_s,
                    starting_time: '14h')
      create(:notification_type, appointment_type: appointment_type)

      visit new_convict_path

      select 'M.', from: 'Civilité'
      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'

      expect { click_button 'submit-with-appointment' }.to change { Convict.count }.by(1)
      expect(page).to have_current_path(new_appointment_path(convict_id: Convict.last.id))

      select 'Premier contact Spip', from: :appointment_appointment_type_id
      select 'McDo de Clichy', from: 'Lieu'
      select 'Agenda de Jean-Louis', from: 'Agenda'

      choose '14:00'

      expect(page).to have_button('Enregistrer')
      click_button 'Enregistrer'
      expect { click_button 'Oui' }.to change { Appointment.count }.by(1)
    end

    it 'rataches a convict to user organization jurisdiction & department at creation' do
      dpt81 = create :department, name: 'Tarn', number: '81'
      juri81 = create :jurisdiction, name: "Tribunal d'Albi"
      orga = create :organization, name: 'test_orga'
      create :areas_organizations_mapping, organization: orga, area: dpt81
      create :areas_organizations_mapping, organization: orga, area: juri81
      user = create :user, organization: orga
      logout_current_user
      login_user user
      visit new_convict_path
      select 'M.', from: 'Civilité'
      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'
      expect { click_button 'submit-no-appointment' }.to change(AreasConvictsMapping, :count).from(0).to(2)
    end
  end

  describe 'update' do
    it 'update convict informations' do
      convict = create(:convict, last_name: 'Expresso')
      visit convicts_path
      within first('.convicts-item-container') { click_link 'Modifier' }
      fill_in 'Nom', with: 'Ristretto'
      click_button 'Enregistrer'
      convict.reload
      expect(convict.last_name).to eq('Ristretto')
    end

    it 'updates convict departments' do
      create :department, number: '09', name: 'Ariège'
      create(:convict, last_name: 'Expresso')
      visit convicts_path
      within first('.convicts-item-container') { click_link 'Modifier' }
      within '#department-form' do
        select 'Ariège', from: :areas_convicts_mapping_area_id
        expect { click_button 'Ajouter' }.to change(AreasConvictsMapping, :count).from(0).to(1)
        expect(page).to have_content('(09) Ariège')
        expect { click_link 'Supprimer' }.to change(AreasConvictsMapping, :count).from(1).to(0)
      end
      expect(page).not_to have_content('(09) Ariège')
    end

    it 'updates convict jurisdictions' do
      create :jurisdiction, name: 'Juridiction de Nanterre'
      create(:convict, last_name: 'Expresso')
      visit convicts_path
      within first('.convicts-item-container') { click_link 'Modifier' }
      within '#jurisdiction-form' do
        select 'Juridiction de Nanterre', from: :areas_convicts_mapping_area_id
        expect { click_button 'Ajouter' }.to change(AreasConvictsMapping, :count).from(0).to(1)
        expect(page).to have_content('Juridiction de Nanterre')
        expect { click_link 'Supprimer' }.to change(AreasConvictsMapping, :count).from(1).to(0)
      end
    end
  end

  describe 'show' do
    before do
      @convict = create(:convict, last_name: 'Noisette',
                                  first_name: 'Café',
                                  phone: '0607060706')
    end

    it 'displays infos on convict' do
      place = create(:place, name: 'SPIP du 93')
      agenda = create(:agenda, place: place)

      slot1 = create(:slot, agenda: agenda,
                            date: '06/10/2021',
                            starting_time: new_time_for(13, 0))

      slot2 = create(:slot, agenda: agenda,
                            date: '08/12/2021',
                            starting_time: new_time_for(15, 30))

      create(:appointment, slot: slot1, convict: @convict)
      create(:appointment, slot: slot2, convict: @convict)

      visit convict_path(@convict)

      expect(page).to have_content('Café')
      expect(page).to have_content('NOISETTE')
      expect(page).to have_content('06 07 06 07 06')
    end

    it 'allows to delete convict' do
      visit convict_path(@convict)

      within first('.show-profile-container') do
        expect { click_button('Supprimer') }.to change { Convict.count }.by(-1)
      end
    end
  end

  describe 'Archive' do
    it 'an agent archive a convict' do
      dpt01 = create :department, number: '01', name: 'Ain'
      orga = create :organization
      user = create :user, role: 'cpip', organization: orga
      create :areas_organizations_mapping, organization: orga, area: dpt01
      convict_dpt01 = create :convict, first_name: 'babar', last_name: 'BABAR'
      create :areas_convicts_mapping, convict: convict_dpt01, area: dpt01
      login_user user
      visit convicts_path
      expect(page).to have_content('BABAR Babar')
      click_link 'Archiver'
      expect(page).not_to have_content('BABAR Babar')
      expect(page).not_to have_content('Désarchiver')
    end

    it 'an admin archive and unarchive a convict' do
      dpt01 = create :department, number: '01', name: 'Ain'
      orga = create :organization
      user = create :user, role: 'cpip', organization: orga
      create :areas_organizations_mapping, organization: orga, area: dpt01
      convict_dpt01 = create :convict, first_name: 'babar', last_name: 'BABAR'
      create :areas_convicts_mapping, convict: convict_dpt01, area: dpt01
      visit convicts_path
      expect(page).to have_content('BABAR Babar')
      click_link 'Archiver'
      expect(page).to have_content('BABAR Babar')
      expect(Convict.exists?(id: convict_dpt01.id)).to be false
      click_link 'Désarchiver'
      expect(page).to have_content('BABAR Babar')
      expect(Convict.exists?(id: convict_dpt01.id)).to be true
    end
  end
end
