require 'rails_helper'

RSpec.feature 'Convicts', type: :feature do
  before do
    #@user = create_admin_user_and_login
    # TODO : we should not have to return Place.all. The factory should add places to the user's organization
    allow(Place).to receive(:in_departments).and_return(Place.all)
  end

  describe 'index', logged_in_as: 'cpip' do
    it 'allows an agent to assign himself to a convict' do
      create(:convict, first_name: 'Bernard', phone: '0607080910', organizations: [@cpip.organization])
      visit convicts_path
      within first('.convicts-item-container') do
        click_link('attribuer cette PPSMJ')
      end
      expect(page).to have_content('La PPSMJ vous a bien été attribuée.')
      expect(page).to have_content(@cpip.name)
      expect(Convict.first.cpip).to eq(@cpip)
    end

    it 'an agent see only convict from his organization (TODO : and linked organization ?)' do
      create(:convict, first_name: 'Michel', last_name: 'Vaillant', organizations: [@cpip.organization])
      create(:convict, first_name: 'Paul', last_name: 'Personne', organizations: [@cpip.organization])

      organization = create :organization
      create(:convict, first_name: 'Max', last_name: 'Dupneu', organizations: [organization])
      create(:convict, first_name: 'Tom', last_name: 'Dupont', organizations: [organization])

      visit convicts_path
      expect(page).not_to have_content('Max')
      expect(page).not_to have_content('Tom')
      expect(page).to have_content('VAILLANT Michel').twice
      expect(page).to have_content('PERSONNE Paul').twice
    end

    it 'an agent can list only the convicts assigned to him' do
      create(:convict, first_name: 'Michel', last_name: 'Vaillant', organizations: [@cpip.organization], user: @cpip)
      create(:convict, first_name: 'Paul', last_name: 'Personne', organizations: [@cpip.organization])

      visit convicts_path(only_mine: true)

      expect(page).to have_content('Michel').twice
      expect(page).to have_content('Paul').once
    end
  end

  describe 'creation', logged_in_as: 'cpip' do
    it 'creates a convict with his first appointment', js: true do
      appointment_type = create(:appointment_type, :with_notification_types, name: "Sortie d'audience SPIP")
      place = create :place, name: 'McDo de Clichy',
                             appointment_types: [appointment_type],
                             organization: @cpip.organization
      agenda = create(:agenda, place: place, name: 'Agenda de Jean-Louis')

      create(:agenda, place: place, name: 'Agenda de Michel')
      create(:slot, agenda: agenda,
                    appointment_type: appointment_type,
                    date: Date.civil(2025, 4, 14),
                    starting_time: new_time_for(14, 0))
      create(:notification_type, appointment_type: appointment_type)

      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'

      expect { click_button 'submit-with-appointment' }.to change { Convict.count }.by(1)
      expect(page).to have_current_path(new_appointment_path(convict_id: Convict.last.id))

      select "Sortie d'audience SPIP", from: "appointment_appointment_type_id"
      select 'McDo de Clichy', from: 'appointment-form-place-select'
      select 'Agenda de Jean-Louis', from: 'Agenda'

      choose '14:00'

      expect(page).to have_button('Enregistrer')
      click_button 'Enregistrer'
      expect { click_button 'Oui' }.to change { Appointment.count }.by(1)
    end

    it 'creates a convict without a phone number' do
      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      check 'Ne possède pas de téléphone portable'

      expect { click_button 'submit-no-appointment' }.to change { Convict.count }.by(1)
    end

    describe 'with potentially duplicated convicts' do
      it 'shows a warning with link to pre-existing convict profile' do
        convict = create(:convict, first_name: 'roberta', last_name: 'dupond')
        create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

        visit new_convict_path

        fill_in 'Prénom', with: 'Roberta'
        fill_in 'Nom', with: 'Dupond'
        fill_in 'Téléphone', with: '0606060606'
        expect { click_button('submit-no-appointment') }.not_to change(Convict, :count)

        expect(page).to have_content('Un doublon potentiel a été détecté :')
        expect(page).to have_link('Profil de DUPOND Roberta', href: convict_path(convict))

        expect { click_button('submit-no-appointment') }.to change(Convict, :count).by(1)
      end

      it 'shows a generic warning if the pre-existing convict is outside of department' do
        convict = create(:convict, first_name: 'Roberto', last_name: 'Durand')
        department = create(:department, name: 'Sarthe', number: '72')
        create :areas_convicts_mapping, convict: convict, area: department

        visit new_convict_path

        fill_in 'Prénom', with: 'Roberto'
        fill_in 'Nom', with: 'Durand'
        fill_in 'Téléphone', with: '0606060606'
        expect { click_button('submit-no-appointment') }.not_to change(Convict, :count)

        expect(page).to have_content(
          "Un homonyme existe dans le département #{department.name} (#{department.number})."
        )

        expect { click_button('submit-no-appointment') }.to change(Convict, :count).by(1)
      end
    end

    it 'creates a convicts with a cpip relation', js: true do
      create(:user, first_name: 'Damien', last_name: 'LET', role: 'cpip')
      cpip = create(:user, first_name: 'Rémy', last_name: 'MAU', role: 'cpip', organization: @cpip.organization)

      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'
      find('#new_convict > div.form-input-wrapper.select.optional.convict_user > span > span.selection > span').click
      find('li.select2-results__option', text: 'MAU Rémy').click

      click_button 'submit-no-appointment'

      expect(Convict.first.cpip).to eq(cpip)
    end

    it 'fills in the convict creating organization' do
      orga = create :organization, name: 'test_orga'
      user = create :user, organization: orga
      logout_current_user
      login_user user
      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'
      click_button 'submit-no-appointment'
      expect(Convict.last.creating_organization).to eq(orga)
    end
  end

  describe 'update', logged_in_as: 'cpip' do
    it 'update convict informations', js: true do
      convict = create(:convict, last_name: 'Expresso', organizations: [@cpip.organization])
      cpip = create(:user, first_name: 'Rémy', last_name: 'MAU', role: 'cpip', organization: @cpip.organization)
      visit edit_convict_path(convict)
      fill_in 'Nom', with: 'Ristretto'
      find('form > div.form-input-wrapper.select.optional.convict_user > span > span.selection > span').click
      find('li.select2-results__option', text: 'MAU Rémy').click
      click_button 'Enregistrer'
      convict.reload
      expect(convict.last_name).to eq('Ristretto')
      expect(convict.cpip).to eq(cpip)
    end

    it 'creates a history_item if the phone number is updated' do
      convict = create(:convict, phone: '0606060606', organizations: [@cpip.organization])
      visit edit_convict_path(convict)
      fill_in 'Téléphone portable', with: '0707070707'
      expect { click_button('Enregistrer') }.to change { HistoryItem.count }.by(1)
      visit convict_path(convict)
      expected_content = "Le numéro de téléphone de #{convict.name} a été modifié par #{@cpip.name} (#{@cpip.role}). " \
                         'Ancien numéro : 06 06 06 06 06 / Nouveau numéro : 07 07 07 07 07.'

      expect(page).to have_content(expected_content)
    end

    it 'creates a history_item if a new phone number is added' do
      convict = create(:convict, phone: nil, no_phone: true, organizations: [@cpip.organization])

      visit edit_convict_path(convict)

      fill_in 'Téléphone portable', with: '0707070707'

      expect { click_button('Enregistrer') }.to change { HistoryItem.count }.by(1)

      visit convict_path(convict)

      expected_content = "Un numéro de téléphone pour #{convict.name} a été ajouté " \
                         "par #{@cpip.name} (#{@cpip.role}). Nouveau numéro : 07 07 07 07 07."

      expect(page).to have_content(expected_content)
    end

    it 'creates a history_item if the phone number is removed' do
      convict = create(:convict_with_organizations, phone: '0606060606')
      visit edit_convict_path(convict)

      fill_in 'Téléphone portable', with: ''
      check 'Ne possède pas de téléphone portable'

      expect { click_button('Enregistrer') }.to change { HistoryItem.count }.by(1)

      visit convict_path(convict)

      expected = "Le numéro de téléphone de #{convict.name} a été supprimé par #{@user.name} (#{@user.role}). " \
                 'Ancien numéro : 06 06 06 06 06.'

      expect(page).to have_content(expected)
    end
  end

  describe 'show', logged_in_as: 'cpip' do
    before do
      @convict = create(:convict, last_name: 'Noisette',
                                  first_name: 'Café',
                                  phone: '0607060706', organizations: [@cpip.organization])
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

    it 'allows a dpip to assign himself to a convict' do
      logout_current_user
      dpip = create(:user, role: 'dpip')
      login_as(dpip, scope: :user)

      visit convict_path(@convict)

      click_link('attribuer cette PPSMJ')
      expect(page).to have_content('La PPSMJ vous a bien été attribuée.')
      expect(page).to have_content(dpip.name)
      expect(Convict.first.cpip).to eq(dpip)
    end

    it 'allow a cpip to invite a convict to his interface and displays the correct content', logged_in_as: 'cpip' do
      @cpip.update(email: 'delphine.deneubourg@justice.fr')
      visit convict_path(@convict)
      expect(page).to have_content('Jamais invité')
      expect(page).to have_content("Aucun accès pour l'instant")
      expect { click_button('Inviter à son espace') }.to have_enqueued_job(InviteConvictJob).once

      @convict.update(invitation_to_convict_interface_count: 1)
      visit convict_path(@convict)
      expect(page).to have_content('Invité')

      @convict.update(timestamp_convict_interface_creation: Time.zone.now)
      visit convict_path(@convict)
      expect(page).to have_content('Accepté')
    end
  end

  describe 'archive' do
    it 'an agent can archive a convict', logged_in_as: 'cpip' do
      convict = create(:convict, first_name: 'babar', last_name: 'BABAR', phone: '0606060606', organizations: [@cpip.organization])
      visit convicts_path

      expect(page).to have_content('BABAR Babar')

      click_link 'Archiver'

      expect(page).to have_content('BABAR Babar (archivé)')
      expect(page).not_to have_content('Désarchiver')
    end

    it 'an admin can archive and unarchive a convict', logged_in_as: 'admin' do
      convict = create(:convict, first_name: 'babar', last_name: 'BABAR', phone: '0606060606', organizations: [@admin.organization])

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
