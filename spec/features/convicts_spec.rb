require 'rails_helper'
require_relative '../support/shared_examples/convict_search_examples'

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
      expect(page).to have_content(/Vaillant/i)
      expect(page).to have_content(/Personne/i)
    end

    it 'an agent can list only the convicts assigned to him', js: true do
      create(:convict, first_name: 'Michel', last_name: 'Vaillant', date_of_birth: '01/01/1980',
                       organizations: [@user.organization], user: @user)
      create(:convict, first_name: 'Paul', last_name: 'Personne', date_of_birth: '01/01/1980',
                       organizations: [@user.organization])

      visit convicts_path

      page.find('label[for="my_convicts_checkbox"]').click

      expect(page).to have_content(/Vaillant/i)
      expect(page).to have_no_content(/Personne/i)
    end

    it_behaves_like 'convict search feature'
  end

  describe 'creation', logged_in_as: 'cpip' do
    it 'creates a convict with his first appointment', js: true do
      appointment_type = create(:appointment_type, :with_notification_types, organization: @user.organization,
                                                                             name: "Sortie d'audience SPIP")
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

    it 'creates a convicts with a cpip relation', logged_in_as: 'cpip', js: true do
      cpip = create(:user, first_name: 'Rémy', last_name: 'MAU', role: 'cpip', organization: @user.organization)

      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'
      fill_in 'Date de naissance', with: '1980-01-01'

      find('#convict_user_id').set('Mau')
      page.has_content?('MAU Rémy')
      find('a', text: 'MAU Rémy').click

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

    it 'invites the convict to its interface by default for qualified roles' do
      user = create :user, :in_organization, role: 'cpip'
      logout_current_user
      login_user user
      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'
      fill_in 'Date de naissance', with: '01/01/1980'
      click_button 'submit-no-appointment'
      expect(InviteConvictJob).to have_been_enqueued.exactly(:once).with(Convict.last.id)
    end

    it 'does not invite the convict to its interface if checkbox not selected' do
      user = create :user, :in_organization, role: 'cpip'
      logout_current_user
      login_user user
      visit new_convict_path

      uncheck('invite_convict')
      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'
      fill_in 'Date de naissance', with: '01/01/1980'
      click_button 'submit-no-appointment'
      expect(InviteConvictJob).not_to have_been_enqueued
    end

    it 'does not invite the convict to its interface by default for unqualified roles' do
      user = create :user, :in_organization, type: :tj, role: 'bex'
      logout_current_user
      login_user user
      visit new_convict_path

      fill_in 'Prénom', with: 'Robert'
      fill_in 'Nom', with: 'Durand'
      fill_in 'Téléphone', with: '0606060606'
      fill_in 'Date de naissance', with: '01/01/1980'
      click_button 'submit-no-appointment'
      expect(InviteConvictJob).not_to have_been_enqueued
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
      page.has_content?('MAU Rémy')

      find('a', text: 'MAU Rémy').click

      click_button 'Enregistrer'

      convict.reload
      expect(convict.last_name).to eq('RISTRETTO')
      expect(convict.cpip).to eq(cpip)
    end

    it 'add to TJ Paris if japat is selected', js: true do
      tj_paris = create(:organization, name: 'TJ Paris', organization_type: 'tj')
      convict = create(:convict, last_name: 'Expresso', date_of_birth: '01/01/1980',
                                 organizations: [@user.organization])
      create(:user, first_name: 'Rémy', last_name: 'MAU', role: 'cpip', organization: @user.organization)

      visit edit_convict_path(convict)

      japat_checkbox = find('#convict-japat-checkbox')
      japat_checkbox.check(id: 'convict-japat', allow_label_click: true)

      click_button 'Enregistrer'

      convict.reload
      expect(convict.organizations).to match([@user.organization, tj_paris])
      expect(convict.japat).to be_truthy

      visit edit_convict_path(convict)
      expect(find('input#convict-japat', visible: :all)).to be_disabled
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
      tj2 = build(:organization, organization_type: 'tj')
      tj2.spips = [spip2]
      tj2.save
      srj_tj = create(:srj_tj, organization: tj2)
      srj_spip = create(:srj_spip, organization: spip2)

      create(:city, srj_tj:, srj_spip:)
      create_appointment(convict, tj, date: 1.month.ago)
      visit edit_convict_path(convict)

      find('#convict_city_id').set('Melun')

      page.has_content?('77000 Melun (France)')
      find('a', text: '77000 Melun (France)').click

      orgs_info_div = page.find("div[data-search-cities-results-target='organizationsInfo']")

      expect(orgs_info_div).to have_content("pour cette commune: #{tj2.name}, #{spip2.name}")

      click_button 'Enregistrer'
      convict.reload
      expect(convict.organizations).to match_array([spip, tj, spip2, tj2])
      expect(convict.being_divested?).to be(true)
    end

    it 'it auto divest convict when city is updated if possible', logged_in_as: 'bex',
                                                                  js: true do
      @user.organization.use_inter_ressort = true

      spip = create(:organization, organization_type: 'spip')
      tj = create(:organization, organization_type: 'tj')

      convict = create(:convict, phone: nil, no_phone: true, organizations: [spip, tj])

      spip2 = create(:organization, organization_type: 'spip')
      tj2 = build(:organization, organization_type: 'tj')
      tj2.spips = [spip2]
      tj2.save
      srj_tj = create(:srj_tj, organization: tj2)
      srj_spip = create(:srj_spip, organization: spip2)

      create(:city, srj_tj:, srj_spip:)
      visit edit_convict_path(convict)

      find('#convict_city_id').set('Melun')

      page.has_content?('77000 Melun (France)')
      find('a', text: '77000 Melun (France)').click

      orgs_info_div = page.find("div[data-search-cities-results-target='organizationsInfo']")

      expect(orgs_info_div).to have_content("pour cette commune: #{tj2.name}, #{spip2.name}")

      click_button 'Enregistrer'
      convict.reload
      expect(convict.organizations).to match_array([spip2, tj2])
      expect(convict.being_divested?).to be(false)
      expect(convict.divestments.last.state).to eq('auto_accepted')
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

      it 'allows a cpip to invite a convict to his interface and displays the correct content',
         logged_in_as: 'cpip' do
        @user.update(email: 'delphine.deneubourg@justice.fr')
        @convict.update(user: @user)
        visit convict_path(@convict)
        expect(page).to have_content('Jamais invité')
        expect(page).to have_content("Aucun accès pour l'instant")
        expect { click_button('Inviter à son espace') }.to have_enqueued_job(InviteConvictJob).once.with(@convict.id)

        @convict.update(invitation_to_convict_interface_count: 1)
        visit convict_path(@convict)
        expect(page).to have_content('Invité')

        @convict.update(timestamp_convict_interface_creation: Time.zone.now)
        visit convict_path(@convict)
        expect(page).to have_content('Accepté')
      end

      it 'does not allow to invite a convict without phone number to his interface',
         logged_in_as: 'cpip' do
        @convict.update(user: @user, phone: nil, no_phone: true)
        visit convict_path(@convict)
        expect(page).to have_content("Impossible d'inviter ce probationnaire")
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
