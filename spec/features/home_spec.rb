require 'rails_helper'
require_relative '../support/shared_examples/convict_search_examples'

RSpec.feature 'Home', type: :feature do
  describe 'Logged as JAP', logged_in_as: 'jap' do
    before do
      @appointment_type = create :appointment_type, :with_notification_types, organization: @user.organization
      visit home_path
    end

    it 'loads' do
      expect(page).to have_selector('//input', id: 'convicts_search_field')
    end

    it 'should display a link to a page listing uninformed appointments' do
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

    it 'should not display a link to a page listing uninformed appointments' do
      expect(page).not_to have_content('le statut de plusieurs convocations de votre service n’a pas été renseigné.')
    end
  end

  describe 'Logged as CPIP', logged_in_as: 'cpip' do
    before do
      @appointment_type = create :appointment_type, :with_notification_types, organization: @user.organization
    end

    it 'should display a link to a page with the user uninformed appointments for cpip users' do
      place = create :place, organization: @user.organization
      @agenda = create(:agenda, place:)
      @convict = create(:convict, organizations: [@user.organization], user: @user)

      slot1 = create(:slot, :without_validations, agenda: @agenda, appointment_type: @appointment_type,
                                                  date: next_valid_day(date: Date.today - 2.months),
                                                  starting_time: new_time_for(13, 0))
      slot2 = create(:slot, agenda: @agenda, appointment_type: @appointment_type,
                            date: next_valid_day(date: Date.today - 2.months),
                            starting_time: new_time_for(15, 30))

      slot3 = create(:slot, agenda: @agenda, appointment_type: @appointment_type,
                            date: next_valid_day(date: Date.today - 2.months),
                            starting_time: new_time_for(12, 30))

      slot4 = create(:slot, agenda: @agenda, appointment_type: @appointment_type,
                            date: next_valid_day(date: Date.today - 2.months),
                            starting_time: new_time_for(15, 30))

      slot5 = create(:slot, agenda: @agenda, appointment_type: @appointment_type,
                            date: next_valid_day(date: Date.today - 2.months),
                            starting_time: new_time_for(15, 30))

      slot6 = create(:slot, agenda: @agenda, appointment_type: @appointment_type,
                            date: next_valid_day(date: Date.today - 2.months),
                            starting_time: new_time_for(15, 30))

      @appointment1 = build :appointment, :with_notifications, convict: @convict, slot: slot1, user: @user
      @appointment1.save validate: false
      @appointment1.book

      @appointment2 = build :appointment, :with_notifications, convict: @convict, slot: slot2, user: @user
      @appointment2.save validate: false
      @appointment2.book

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

      visit home_path

      expect(page).to have_content("le statut de plusieurs convocations que vous avez effectuées n'a pas été renseigné.")

      within first('div.fr-alert', text: 'Attention') do
        click_on('Cliquez ici pour le renseigner simplement')
      end

      expect(page).to have_content('Convocations au statut inconnu')
      expect(page).to have_selector('tr', count: 7)
    end

    it_behaves_like 'convict search feature'
  end
end
