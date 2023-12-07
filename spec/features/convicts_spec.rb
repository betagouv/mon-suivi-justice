require 'rails_helper'

RSpec.feature 'Convicts', type: :feature do
  describe 'index', logged_in_as: 'cpip' do
    it 'allows an agent to assign himself to a convict' do
      create(:convict, first_name: 'Bernard', phone: '0607080910', date_of_birth: '01/01/1980',
                       organizations: [@user.organization])
      visit convicts_path
      within first('tbody') do
        click_link('S\'attribuer ce probationnaire')
      end
      expect(page).to have_content('Le probationnaire vous a bien été attribué.')
      expect(page).to have_content(@user.name)
      expect(Convict.first.cpip).to eq(@user)
    end

    it 'an agent see only convict from his organization' do
      create(:convict, first_name: 'Michel', last_name: 'Vaillant', date_of_birth: '01/01/1980',
                       organizations: [@user.organization])
      create(:convict, first_name: 'Paul', last_name: 'Personne', date_of_birth: '01/01/1980',
                       organizations: [@user.organization])

      organization = create :organization
      create(:convict, first_name: 'Max', last_name: 'Dupneu', organizations: [organization])
      create(:convict, first_name: 'Tom', last_name: 'Dupont', organizations: [organization])

      visit convicts_path

      expect(page).not_to have_content('Dupneu')
      expect(page).not_to have_content('Dupont')
      expect(page).to have_content('Vaillant')
      expect(page).to have_content('Personne')
    end

    it 'an agent can list only the convicts assigned to him', js: true do
      create(:convict, first_name: 'Michel', last_name: 'Vaillant', date_of_birth: '01/01/1980',
                       organizations: [@user.organization], user: @user)
      create(:convict, first_name: 'Paul', last_name: 'Personne', date_of_birth: '01/01/1980',
                       organizations: [@user.organization])

      visit convicts_path

      page.find('label[for="my_convicts_checkbox"]').click

      expect(page).to have_content('Vaillant')
      expect(page).to have_no_content('Personne')
    end
  end

  describe 'creation', logged_in_as: 'cpip' do
    it 'creates a convict with his first appointment', js: true do
      appointment_type = create(:appointment_type, :with_notification_types, name: "Sortie d'audience SPIP")
      place = create :place, name: 'McDo de Clichy',
                             appointment_types: [appointment_type],
                             organization: @user.organization
      agenda = create(:agenda, place:, name: 'Agenda de Jean-Louis')

      create(:agenda, place:, name: 'Agenda de Michel')
      create(:slot, agenda:,
                    appointment_type:,
                    date: Date.civil(2025, 4, 14),
                    starting_time: new_time_for(14, 0))
      create(:notification_type, appointment_type:)

      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'
      fill_in 'Date de naissance', with: '1980-01-01'

      expect { click_button 'submit-with-appointment' }.to change { Convict.count }.by(1)
      expect(page).to have_current_path(new_appointment_path(convict_id: Convict.last.id))

      select "Sortie d'audience SPIP", from: 'appointment_appointment_type_id'
      select 'McDo de Clichy', from: 'appointment-form-place-select'
      select 'Agenda de Jean-Louis', from: 'Agenda'

      choose '14:00'

      page.find('label[for="send_sms_1"]').click

      expect(page).to have_button('Convoquer')
      expect { click_button 'Convoquer' }.to change { Appointment.count }.by(1)
    end

    it 'creates a convict without a phone number' do
      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Date de naissance', with: '01/01/1980'
      check 'Ne possède pas de téléphone portable'

      expect { click_button 'submit-no-appointment' }.to change { Convict.count }.by(1)
    end

    it 'it assigns the current user organizations to the convict if no city specified' do
      tj = create(:organization, organization_type: 'tj')
      @user.organization.tjs.push(tj)

      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Date de naissance', with: '01/01/1980'
      check 'Ne possède pas de téléphone portable'

      expect { click_button 'submit-no-appointment' }.to change { Convict.count }.by(1)
      expect(Convict.first.organizations).to match_array([@user.organization, tj])
    end

    it 'it assigns the city organizations to the convict if a city is selected', logged_in_as: 'bex', js: true do
      @user.organization.use_inter_ressort = true
      spip = create(:organization, organization_type: 'spip')
      tj = create(:organization, organization_type: 'tj')
      srj_tj = create(:srj_tj, organization: tj)
      srj_spip = create(:srj_spip, organization: spip)

      city = create(:city, srj_tj:, srj_spip:)

      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Date de naissance', with: '1980-01-01'

      find('#convict_city_id').set('Melun')

      page.has_content?('77000 Melun (France)')

      find('a', text: '77000 Melun (France)').click

      orgs_info_div = page.find("div[data-search-cities-results-target='organizationsInfo']")
      expect(orgs_info_div).to have_content("#{tj.name}, #{spip.name}")

      no_phone_cb = find('#convict-no-phone-checkbox')
      no_phone_cb.check(id: 'convict-no-phone', allow_label_click: true)

      expect { click_button 'submit-no-appointment' }.to change { Convict.count }.by(1)

      expect(Convict.first.organizations.pluck(:id)).to match_array(city.organizations.pluck(:id))
    end

    it 'it assigns the city spip and TJ Paris to the convict if a city is selected and japat is selected',
       logged_in_as: 'bex', js: true do
      @user.organization.use_inter_ressort = true
      spip = create(:organization, organization_type: 'spip')

      tj = create(:organization, organization_type: 'tj')
      tj_paris = create(:organization, name: 'TJ Paris', organization_type: 'tj')
      srj_tj = create(:srj_tj, organization: tj)
      srj_spip = create(:srj_spip, organization: spip)

      create(:city, srj_tj:, srj_spip:)

      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Date de naissance', with: '1980-01-01'

      find('#convict_city_id').set('Melun')
      find('a', text: '77000 Melun (France)').click

      japat_checkbox = find('#convict-japat-checkbox')
      japat_checkbox.check(id: 'convict-japat', allow_label_click: true)
      no_phone_cb = find('#convict-no-phone-checkbox')
      no_phone_cb.check(id: 'convict-no-phone', allow_label_click: true)

      expect { click_button 'submit-no-appointment' }.to change { Convict.count }.by(1)

      expect(Convict.last.organizations).to match_array([spip, tj_paris])
    end

    describe 'with potentially duplicated convicts', logged_in_as: 'cpip', js: true do
      it 'shows a warning with link to potential first name / last name / date of birth duplicates' do
        convict = create(:convict, first_name: 'roberta', last_name: 'dupond', date_of_birth: '01/01/1980',
                                   organizations: [@user.organization])

        visit new_convict_path

        fill_in 'Prénom', with: 'Roberta'
        fill_in 'Nom', with: 'Dupond'
        fill_in 'Date de naissance', with: '1980-01-01'
        fill_in 'Téléphone', with: '0707070707'

        expect { click_button('submit-no-appointment') }.not_to change(Convict, :count)

        expect(page).to have_content('Un doublon potentiel a été détecté :')
        expect(page).to have_link("DUPOND Roberta, suivi(e) par : #{convict.organizations.first.name}",
                                  href: convict_path(convict))

        expect { click_button('submit-no-appointment') }.to change(Convict, :count).by(1)
      end

      it 'shows a warning with link to potential first name / last name / phone duplicates' do
        convict = create(:convict, first_name: 'roberta', last_name: 'dupond', phone: '+33606060606',
                                   date_of_birth: '01/01/1980',
                                   organizations: [@user.organization])

        visit new_convict_path

        fill_in 'Prénom', with: 'Roberta'
        fill_in 'Nom', with: 'Dupond'
        fill_in 'Date de naissance', with: '1970-01-01'
        fill_in 'Téléphone', with: '0606060606'

        expect { click_button('submit-no-appointment') }.not_to change(Convict, :count)

        expect(page).to have_content('Un doublon potentiel a été détecté :')
        expect(page).to have_link("DUPOND Roberta, suivi(e) par : #{convict.organizations.first.name}",
                                  href: convict_path(convict))

        expect { click_button('submit-no-appointment') }.not_to change(Convict, :count)

        expect(page).to have_content('Un probationnaire est déjà enregistré avec ce numéro de téléphone.')
      end
    end

    it 'creates a convicts with a cpip relation', logged_in_as: 'cpip', js: true do
      cpip = create(:user, first_name: 'Rémy', last_name: 'MAU', role: 'cpip', organization: @user.organization)

      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'
      fill_in 'Date de naissance', with: '1980-01-01'

      find('#convict_user_id').set('Mau')
      page.has_content?('Rémy MAU')
      find('a', text: 'Rémy MAU').click

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
      fill_in 'Date de naissance', with: '01/01/1980'
      click_button 'submit-no-appointment'
      expect(Convict.last.creating_organization).to eq(orga)
    end
  end

  describe 'update', logged_in_as: 'cpip' do
    it 'update convict informations', js: true do
      convict = create(:convict, last_name: 'Expresso', date_of_birth: '01/01/1980',
                                 organizations: [@user.organization])
      cpip = create(:user, first_name: 'Rémy', last_name: 'MAU', role: 'cpip', organization: @user.organization)

      visit edit_convict_path(convict)

      find('#convict_last_name').set('').set('Ristretto')

      find('#convict_user_id').set('Mau')
      page.has_content?('Rémy MAU')

      find('a', text: 'Rémy MAU').click

      click_button 'Enregistrer'

      convict.reload
      expect(convict.last_name).to eq('Ristretto')
      expect(convict.cpip).to eq(cpip)
    end

    it 'creates a history_item if the phone number is updated' do
      convict = create(:convict, phone: '0606060606', organizations: [@user.organization])
      visit edit_convict_path(convict)
      fill_in 'Téléphone portable', with: '0707070707'
      expect { click_button('Enregistrer') }.to change { HistoryItem.count }.by(1)
      visit convict_path(convict)
      expected_content = "Le numéro de téléphone de #{convict.name} a été modifié par #{@user.name} (#{@user.role}). " \
                         'Ancien numéro : 06 06 06 06 06 / Nouveau numéro : 07 07 07 07 07.'

      expect(page).to have_content(expected_content)
    end

    it 'creates a history_item if a new phone number is added' do
      convict = create(:convict, phone: nil, no_phone: true, organizations: [@user.organization])

      visit edit_convict_path(convict)

      fill_in 'Téléphone portable', with: '0707070707'

      expect { click_button('Enregistrer') }.to change { HistoryItem.count }.by(1)

      visit convict_path(convict)

      expected_content = "Un numéro de téléphone pour #{convict.name} a été ajouté " \
                         "par #{@user.name} (#{@user.role}). Nouveau numéro : 07 07 07 07 07."

      expect(page).to have_content(expected_content)
    end

    it 'creates a history_item if the phone number is removed' do
      convict = create(:convict, first_name: 'Bob', last_name: 'Dupneu', phone: '0606060606',
                                 organizations: [@user.organization])
      visit edit_convict_path(convict)

      fill_in 'Téléphone portable', with: ''
      check 'Ne possède pas de téléphone portable'

      expect { click_button('Enregistrer') }.to change { HistoryItem.count }.by(1)

      visit convict_path(convict)

      expected = "Le numéro de téléphone de #{convict.name} a été supprimé par #{@user.name} (#{@user.role}). " \
                 'Ancien numéro : 06 06 06 06 06.'

      expect(page).to have_content(expected)
    end

    it 'displays proper alerts and update convicts organizations correctly when city is updated', logged_in_as: 'bex',
                                                                                                  js: true do
      @user.organization.use_inter_ressort = true

      spip = create(:organization, organization_type: 'spip')
      tj = create(:organization, organization_type: 'tj')

      convict = create(:convict, phone: nil, no_phone: true, organizations: [spip, tj])

      spip2 = create(:organization, organization_type: 'spip')
      tj2 = create(:organization, organization_type: 'tj')
      srj_tj = create(:srj_tj, organization: tj2)
      srj_spip = create(:srj_spip, organization: spip2)

      create(:city, srj_tj:, srj_spip:)

      visit edit_convict_path(convict)

      find('#convict_city_id').set('Melun')

      page.has_content?('77000 Melun (France)')
      find('a', text: '77000 Melun (France)').click

      orgs_info_div = page.find("div[data-search-cities-results-target='organizationsInfo']")

      expect(orgs_info_div).to have_content("pour cette commune: #{tj2.name}, #{spip2.name}")
      expect(orgs_info_div).to have_content("les services actuels du probationnaire: #{spip.name}, #{tj.name}")

      click_button 'Enregistrer'

      expect(Convict.last.organizations).to match_array([spip, tj, spip2, tj2])
    end
  end

  describe 'show' do
    context 'logged in as cpip', logged_in_as: 'cpip' do
      before do
        @convict = create(:convict, last_name: 'Noisette',
                                    first_name: 'Café',
                                    phone: '0607060706', organizations: [@user.organization])
      end

      it 'displays infos on convict' do
        visit convict_path(@convict)

        expect(page).to have_content('Café')
        expect(page).to have_content('NOISETTE')
        expect(page).to have_content('06 07 06 07 06')
      end

      it 'allows a cpip to assign himself to a convict', js: true do
        visit convict_path(@convict)
        click_link('attribuer ce probationnaire')

        expect(page).to have_content('Le probationnaire vous a bien été assigné')
        expect(page).to have_content(@user.name)
        expect(Convict.first.cpip).to eq(@user)
      end

      it 'allow a cpip to invite a convict to his interface and displays the correct content', logged_in_as: 'cpip' do
        @user.update(email: 'delphine.deneubourg@justice.fr')
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

    context 'logged in as admin', logged_in_as: 'admin' do
      it 'allows to delete convict' do
        convict = create(:convict, last_name: 'Noisette',
                                   first_name: 'Café',
                                   date_of_birth: '01/01/1980',
                                   phone: '0607060706', organizations: [@user.organization])
        visit convict_path(convict)
        expect { click_button('Supprimer') }.to change { Convict.count }.by(-1)
      end
    end

    context 'logged in as dpip', logged_in_as: 'dpip' do
      it 'allows a dpip to assign himself to a convict' do
        convict = create(:convict, last_name: 'Noisette',
                                   first_name: 'Café',
                                   phone: '0607060706', organizations: [@user.organization])

        visit convict_path(convict)

        click_link('attribuer ce probationnaire')
        expect(page).to have_content('Le probationnaire vous a bien été attribué.')
        expect(page).to have_content(@user.name)
        expect(Convict.first.cpip).to eq(@user)
      end
    end
  end

  describe 'archive' do
    it 'an agent can archive a convict', logged_in_as: 'cpip', js: true do
      create(:convict, first_name: 'babar', last_name: 'BABAR', phone: '0606060606', date_of_birth: '01/01/1980',
                       organizations: [@user.organization])
      visit convicts_path
      expect(page).to have_content('BABAR')
      accept_alert do
        click_link 'Archiver'
      end

      expect(page).not_to have_content('Désarchiver')
    end

    it 'an admin can archive and unarchive a convict', logged_in_as: 'admin', js: true do
      convict = create(:convict, first_name: 'babar', last_name: 'BABAR', phone: '0606060606',
                                 date_of_birth: '01/01/1980', organizations: [@user.organization])

      visit convicts_path
      expect(page).to have_content('BABAR')

      accept_alert do
        click_link 'Archiver'
      end

      expect(page).to have_content('BABAR')
      expect(Convict.find(convict.id).discarded?).to be true

      click_link 'Désarchiver'

      expect(page).to have_content('BABAR')
      expect(Convict.find(convict.id).discarded?).to be false
    end
  end
end
