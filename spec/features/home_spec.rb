require 'rails_helper'

RSpec.feature 'Home', type: :feature do
  before do
    @appointment_type = create :appointment_type, :with_notification_types
  end

  describe 'Home page', logged_in_as: 'jap' do
    it 'loads' do
      visit home_path
      expect(page).to have_selector('//input', id: 'convicts_search_field')
    end
  end

  it 'should display a link to a page listing uninformed appointments', logged_in_as: 'jap' do
    place = create :place, organization: @user.organization
    @agenda = create(:agenda, place:)

    slot1 = create(:slot, :without_validations, agenda: @agenda, appointment_type: @appointment_type,
                                                date: Date.civil(2022, 5, 26),
                                                starting_time: new_time_for(13, 0))
    slot2 = create(:slot, agenda: @agenda, appointment_type: @appointment_type,
                          date: Date.civil(2022, 6, 27),
                          starting_time: new_time_for(15, 30))

    @convict = create(:convict, organizations: [@user.organization])

    @appointment1 = build :appointment, :with_notifications, convict: @convict, slot: slot1
    @appointment2 = build :appointment, :with_notifications, convict: @convict, slot: slot2
    @appointment1.save validate: false
    @appointment2.save validate: false

    @appointment2.book
  end

  pending 'should display a link to a page listing uninformed appointments' do
    @user.update(role: :jap)
    visit home_path

    expect(page).to have_content("Attention, 50% des convocations de votre service n'ont pas de statut renseigné")

    within first('div.fr-alert', text: 'Attention') do
      click_on('Cliquez ici')
    end

    expect(page).to have_content("Convocation au statut inconnu au #{@user.organization.name}")
    expect(page).to have_content(Date.civil(2022, 6, 27))
    expect(page).to have_content('15:30')
  end

  it 'should display a link to a page with the user uninformed appointments for cpip users', logged_in_as: 'cpip' do
    place = create :place, organization: @user.organization
    @agenda = create(:agenda, place:)

    slot1 = create(:slot, :without_validations, agenda: @agenda, appointment_type: @appointment_type,
                                                date: Date.civil(2022, 5, 26),
                                                starting_time: new_time_for(13, 0))
    slot2 = create(:slot, agenda: @agenda, appointment_type: @appointment_type,
                          date: Date.civil(2022, 6, 27),
                          starting_time: new_time_for(15, 30))

    @convict = create(:convict, organizations: [@user.organization])

    @appointment1 = build :appointment, :with_notifications, convict: @convict, slot: slot1, user: @user
    @appointment2 = build :appointment, :with_notifications, convict: @convict, slot: slot2, user: @user
    @appointment1.save validate: false
    @appointment2.save validate: false

    @appointment2.book
  end

  pending 'should display a link to a page with the user uninformed appointments for cpip users' do
    @user.update(role: :cpip)
    @appointment1.update(user: @user)
    @appointment2.update(user: @user)

    slot3 = create(:slot, agenda: @agenda, appointment_type: @appointment_type,
                          date: Date.civil(2022, 6, 30),
                          starting_time: new_time_for(12, 30))

    appointment3 = build :appointment, :with_notifications, convict: @convict, slot: slot3, user: @user
    appointment3.save validate: false
    appointment3.book

    visit home_path

    expect(page).to have_content("Attention, 67% de vos convocations n'ont pas de statut renseigné")

    within first('div.fr-alert', text: 'Attention') do
      click_on('Cliquez ici')
    end

    expect(page).to have_content('Vos convocations au statut inconnu')
    expect(page).to have_content(Date.civil(2022, 6, 30))
    expect(page).to have_content('12:30')
  end

  it 'should allow user to search convicts by name or phone number', logged_in_as: 'bex', js: true do
    create(:convict, last_name: 'Dupneu',
                     first_name: 'Bob',
                     phone: '0612345678', organizations: [@user.organization])
    create(:convict, last_name: 'Rabbit',
                     first_name: 'Roger',
                     phone: '0787654321', organizations: [@user.organization])

    visit home_path

    search_input = find('#convicts_search_field')
    search_input.set('Bob')

    expect(page).to have_content('Dupneu')
    expect(page).to have_link('Profil')
    expect(page).not_to have_content('Rabbit')

    search_input.set('')
    search_input.set('07876')

    expect(page).to have_content('Rabbit')
    expect(page).to have_link('Profil')
    expect(page).not_to have_content('Dupneu')

    search_input.set('')
    search_input.set('+337876')

    expect(page).to have_content('Rabbit')
    expect(page).to have_link('Profil')
    expect(page).not_to have_content('Dupneu')

    search_input.set('')
    search_input.set('Whatever')
    expect(page).not_to have_content('Dupneu')
    expect(page).not_to have_content('Rabbit')
  end
end
