require 'rails_helper'

RSpec.feature 'Home', type: :feature do
  describe 'Home page' do
    it 'loads' do
      allow(DataCollector::User).to receive_message_chain(:new, :perform)
                                .and_return({ passed_uninformed_percentage: 40 })
      jap_user = create(:user, role: :jap)
      login_user(jap_user)

      visit home_path

      expect(page).to have_content('Trouver une PPSMJ')
    end
  end

  describe 'Uninformed appointments alert' do
    before do
      @user = create_admin_user_and_login

      @appointment_type = create :appointment_type, :with_notification_types

      place = create :place, organization: @user.organization
      @agenda = create :agenda, place: place

      slot1 = create(:slot, :without_validations, agenda: @agenda, appointment_type: @appointment_type,
                                                  date: Date.civil(2022, 5, 26),
                                                  starting_time: new_time_for(13, 0))
      slot2 = create(:slot, agenda: @agenda, appointment_type: @appointment_type,
                            date: Date.civil(2022, 6, 27),
                            starting_time: new_time_for(15, 30))

      @convict = create :convict
      create :areas_convicts_mapping, convict: @convict, area: @user.organization.departments.first

      @appointment1 = build :appointment, :with_notifications, convict: @convict, slot: slot1
      @appointment2 = build :appointment, :with_notifications, convict: @convict, slot: slot2
      @appointment1.save validate: false
      @appointment2.save validate: false

      @appointment2.book
    end

    pending 'should display a link to a page listing uninformed appointments' do
      @user.update(role: :jap)
      visit home_path

      expect(page).to have_content("Attention, 50% des rendez-vous de votre service n'ont pas de statut renseigné")

      within first('p.warning', text: 'Attention') do
        click_on('Cliquez ici')
      end

      expect(page).to have_content("Rendez-vous au statut inconnu au #{@user.organization.name}")
      expect(page).to have_content(Date.civil(2022, 6, 27))
      expect(page).to have_content('15:30')
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

      expect(page).to have_content("Attention, 67% de vos rendez-vous n'ont pas de statut renseigné")

      within first('p.warning', text: 'Attention') do
        click_on('Cliquez ici')
      end

      expect(page).to have_content('Vos rendez-vous au statut inconnu')
      expect(page).to have_content(Date.civil(2022, 6, 30))
      expect(page).to have_content('12:30')
    end
  end
end
