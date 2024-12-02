require 'rails_helper'
require_relative '../support/shared_examples/convict_search_examples'

RSpec.feature 'Home', type: :feature do
  describe 'As a logged user' do
    before do
      @appointment_type = create :appointment_type, :with_notification_types, organization: @user.organization,
                                                                              name: 'Convocation de suivi JAP'
      place = create :place, organization: @user.organization
      @agenda = create(:agenda, place:)

      slot1 = create_ignore_validation(:slot, agenda: @agenda, appointment_type: @appointment_type,
                                              date: next_valid_day(date: Date.today - 2.months),
                                              starting_time: new_time_for(13, 0))
      slot2 = create_ignore_validation(:slot, agenda: @agenda, appointment_type: @appointment_type,
                                              date: next_valid_day(date: Date.today - 2.months),
                                              starting_time: new_time_for(15, 30))

      @convict = create(:convict, organizations: [@user.organization], user: @user)
      @appointment1 = build :appointment, :with_notifications, convict: @convict, slot: slot1, user: @user
      @appointment2 = build :appointment, :with_notifications, convict: @convict, slot: slot2, user: @user
      @appointment1.save validate: false
      @appointment2.save validate: false

      @appointment2.book
    end

    it 'loads', logged_in_as: 'cpip' do
      visit home_path

      expect(page).to have_selector('//input', id: 'convicts_search_field')
    end

    it 'should not display a link to a page listing uninformed appointments to bex users',
       logged_in_as: 'bex' do
      visit home_path

      expect(page).not_to have_content("le statut de plusieurs convocations de votre service n'a pas été renseigné.")
    end

    it 'should display a link to a page listing uninformed appointments', logged_in_as: 'local_admin' do
      visit home_path

      expect(page).to have_content("le statut de plusieurs convocations de votre service n'a pas été renseigné.")

      within first('div.fr-alert', text: 'Attention') do
        click_on('Cliquez ici pour le renseigner simplement')
      end

      expect(page).to have_content('Convocations au statut inconnu')
      expect(page).to have_selector('tr', count: 2)
    end

    it 'should display a link to a page with the user uninformed appointments for cpip users', logged_in_as: 'cpip' do
      slot3 = create_ignore_validation(:slot, agenda: @agenda, appointment_type: @appointment_type,
                                              date: next_valid_day(date: Date.today - 2.months),
                                              starting_time: new_time_for(12, 30))

      slot4 = create_ignore_validation(:slot, agenda: @agenda, appointment_type: @appointment_type,
                                              date: next_valid_day(date: Date.today - 2.months),
                                              starting_time: new_time_for(15, 30))

      slot5 = create_ignore_validation(:slot, agenda: @agenda, appointment_type: @appointment_type,
                                              date: next_valid_day(date: Date.today - 2.months),
                                              starting_time: new_time_for(15, 30))

      slot6 = create_ignore_validation(:slot, agenda: @agenda, appointment_type: @appointment_type,
                                              date: next_valid_day(date: Date.today - 2.months),
                                              starting_time: new_time_for(15, 30))

      slot7 = create_ignore_validation(:slot, agenda: @agenda, appointment_type: @appointment_type,
                                              date: next_valid_day(date: Date.today - 2.months),
                                              starting_time: new_time_for(15, 30))

      appointment3 = build :appointment, :with_notifications, convict: @convict, slot: slot3, user: @user
      appointment3.save validate: false
      appointment3.book

      appointment4 = build :appointment, :with_notifications, convict: @convict, slot: slot4, user: @user
      appointment4.save validate: false
      appointment4.book

      appointment5 = build :appointment, :with_notifications, convict: @convict, slot: slot5, user: @user
      appointment5.save validate: false
      appointment5.book

      appointment6 = build :appointment, :with_notifications, convict: @convict, slot: slot6, user: @user
      appointment6.save validate: false
      appointment6.book

      appointment7 = build :appointment, :with_notifications, convict: @convict, slot: slot7, user: @user
      appointment7.save validate: false
      appointment7.book

      @user2 = create(:user, first_name: 'Michèle', last_name: 'Doe', role: 'cpip', organization: @user.organization)

      slot8 = create_ignore_validation(:slot, agenda: @agenda, appointment_type: @appointment_type,
                                              date: next_valid_day(date: Date.today - 2.months),
                                              starting_time: new_time_for(15, 30))

      appointment8 = build :appointment, :with_notifications, convict: @convict, slot: slot8, user: @user2
      appointment8.save validate: false
      appointment8.book

      visit home_path

      expect(page).to have_content("n'a pas été renseigné.")

      within first('div.fr-alert', text: 'Attention') do
        click_on('Cliquez ici pour le renseigner simplement')
      end

      expect(page).to have_content('Convocations au statut inconnu')
      expect(page).to have_selector('tr', count: 7)
    end

    it_behaves_like 'convict search feature'
  end
end
