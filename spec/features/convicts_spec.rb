require 'rails_helper'

RSpec.feature 'Convicts', type: :feature do
  before do
    @user = create_admin_user_and_login
    allow(Place).to receive(:in_department).and_return(Place.all)
  end

  describe 'index' do
    before do
      convict1 = create(:convict, first_name: 'michel', phone: '0607080910')
      create :areas_convicts_mapping, convict: convict1, area: @user.organization.departments.first
      convict2 = create(:convict, first_name: 'Paul')
      create :areas_convicts_mapping, convict: convict2, area: @user.organization.departments.first
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

    it 'allows a cpip to assign himself to a convict' do
      logout_current_user
      @user = create_cpip_user_and_login
      visit convicts_path
      within first('.convicts-item-container') do
        click_link('attribuer cette PPSMJ')
      end
      expect(page).to have_content('La PPSMJ vous a bien été attribuée.')
      expect(page).to have_content(@user.name)
      expect(Convict.first.cpip).to eq(@user)
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
    it 'creates a convicts with a phone number and a cpip', js: true do
      create(:user, first_name: 'Damien', last_name: 'LET', role: 'cpip')
      cpip = create(:user, first_name: 'Rémy', last_name: 'MAU', role: 'cpip', organization: @user.organization)

      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'
      first('.select2-container', minimum: 1).click
      find('li.select2-results__option', text: 'MAU Rémy').click

      expect { click_button 'submit-no-appointment' }.to change { Convict.count }.by(1)
      expect(Convict.first.cpip).to eq(cpip)
    end

    it 'creates a convicts with a duplicate name' do
      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'

      expect { click_button 'submit-no-appointment' }.to change { Convict.count }.by(1)
    end

    it 'allows to create a convict without a phone number' do
      create(:convict, first_name: 'roberta', last_name: 'dupond')
      visit new_convict_path

      fill_in 'Prénom', with: 'Roberta'
      fill_in 'Nom', with: 'Dupond'
      fill_in 'Téléphone', with: '0606060606'
      expect { click_button('submit-no-appointment') }.not_to change(Convict, :count)
      expect(page).to have_content(
        'Une PPSMJ existe déjà avec ce nom et prénom. Êtes-vous sur(e) de vouloir enregistrer cette PPSMJ ?'
      )
      expect { click_button('submit-no-appointment') }.to change(Convict, :count).by(1)
    end

    it 'creates a convict with his first appointment', js: true do
      appointment_type = create(:appointment_type, :with_notification_types, name: "Sortie d'audience SPIP")
      place = create :place, name: 'McDo de Clichy',
                             appointment_types: [appointment_type],
                             organization: @user.organization
      agenda = create(:agenda, place: place, name: 'Agenda de Jean-Louis')

      create(:agenda, place: place, name: 'Agenda de Michel')
      create(:slot, agenda: agenda,
                    appointment_type: appointment_type,
                    date: Date.today.next_occurring(:monday),
                    starting_time: '14h')
      create(:notification_type, appointment_type: appointment_type)

      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'

      expect { click_button 'submit-with-appointment' }.to change { Convict.count }.by(1)
      expect(page).to have_current_path(new_appointment_path(convict_id: Convict.last.id))

      select "Sortie d'audience SPIP", from: :appointment_appointment_type_id
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

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'
      expect { click_button 'submit-no-appointment' }.to change(AreasConvictsMapping, :count).from(0).to(2)
    end
  end

  describe 'update' do
    it 'update convict informations', js: true do
      convict = create(:convict, last_name: 'Expresso')
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
      cpip = create(:user, first_name: 'Rémy', last_name: 'MAU', role: 'cpip', organization: @user.organization)
      visit convicts_path
      within first('.convicts-item-container') { click_link 'Modifier' }
      fill_in 'Nom', with: 'Ristretto'
      first('.select2-container', minimum: 1).click
      find('li.select2-results__option', text: 'MAU Rémy').click
      click_button 'Enregistrer'
      convict.reload
      expect(convict.last_name).to eq('Ristretto')
      expect(convict.cpip).to eq(cpip)
    end

    it 'updates convict departments' do
      create :department, number: '09', name: 'Ariège'
      convict = create(:convict, last_name: 'Expresso')
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first
      visit convicts_path

      within first('.convicts-item-container') { click_link 'Modifier' }

      within '#department-form' do
        select 'Ariège', from: :areas_convicts_mapping_area_id
        expect { click_button 'Ajouter' }.to change(AreasConvictsMapping, :count).from(1).to(2)
      end

      expect(page).to have_content('(09) Ariège')

      within first('.convict-attachment') do
        expect { click_link 'Supprimer' }.to change(AreasConvictsMapping, :count).from(2).to(1)
      end

      expect(page).not_to have_content('(09) Ariège')
    end

    it 'updates convict jurisdictions' do
      create :jurisdiction, name: 'Juridiction de Nanterre'
      convict = create(:convict, last_name: 'Expresso')
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

      visit convicts_path

      within first('.convicts-item-container') { click_link 'Modifier' }
      within '#jurisdiction-form' do
        select 'Juridiction de Nanterre', from: :areas_convicts_mapping_area_id
        expect { click_button 'Ajouter' }.to change(AreasConvictsMapping, :count).from(1).to(2)
      end

      expect(page).to have_content('Juridiction de Nanterre')
    end

    it 'creates a history_item if the phone number is updated' do
      convict = create(:convict, phone: '0606060606')
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

      visit edit_convict_path(convict)

      fill_in 'Téléphone portable', with: '0707070707'

      expect { click_button('Enregistrer') }.to change { HistoryItem.count }.by(1)

      visit convict_path(convict)

      expected_content = "Le numéro de téléphone de #{convict.name} a été modifié par #{@user.name} (#{@user.role})." \
                         ' Ancien numéro : 06 06 06 06 06 / Nouveau numéro : 07 07 07 07 07'

      expect(page).to have_content(expected_content)
    end
  end

  describe 'show' do
    before do
      @convict = create(:convict, last_name: 'Noisette',
                                  first_name: 'Café',
                                  phone: '0607060706')
      create :areas_convicts_mapping, convict: @convict, area: @user.organization.departments.first
    end

    it 'displays infos on convict' do
      place = create(:place, name: 'SPIP du 93', organization: @user.organization)
      agenda = create(:agenda, place: place)

      slot1 = create(:slot, agenda: agenda,
                            starting_time: new_time_for(13, 0))

      slot2 = create(:slot, agenda: agenda,
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

    it 'allows a cpip to assign himself to a convict' do
      logout_current_user
      @user = create_cpip_user_and_login
      visit convict_path(@convict)

      click_link('attribuer cette PPSMJ')
      expect(page).to have_content('La PPSMJ vous a bien été attribuée.')
      expect(page).to have_content(@user.name)
      expect(Convict.first.cpip).to eq(@user)
    end
  end

  describe 'archive' do
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

      expect(page).to have_content('BABAR Babar (archivé)')
      expect(page).not_to have_content('Désarchiver')
    end

    it 'an admin archive and unarchive a convict' do
      convict = create :convict, first_name: 'babar', last_name: 'BABAR'
      create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

      visit convicts_path
      expect(page).to have_content('BABAR Babar')

      click_link 'Archiver'

      expect(page).to have_content('BABAR Babar')
      expect(Convict.find(convict.id).discarded?).to be true

      click_link 'Désarchiver'

      expect(page).to have_content('BABAR Babar')
      expect(Convict.find(convict.id).discarded?).to be false
    end
  end
end
