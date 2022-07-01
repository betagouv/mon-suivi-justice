require 'rails_helper'

RSpec.feature 'Home', type: :feature do
  describe 'Home page' do
    it 'loads' do
      allow(DataCollector).to receive_message_chain(:new, :perform)
                          .and_return({ passed_uninformed_percentage: 40 })
      jap_user = create(:user, role: :jap)
      login_user(jap_user)

      visit home_path

      expect(page).to have_content('Trouver une PPSMJ')
    end
  end

  describe 'Uninformed appointments alert'
  before do
    user = create_admin_user_and_login

    appointment_type = create :appointment_type
    create :notification_type, role: :no_show, appointment_type: appointment_type
    create :notification_type, role: :reminder, appointment_type: appointment_type

    place = create :place, organization: @user.organization
    agenda = create :agenda, place: place

    slot1 = create(:slot, :without_validations, agenda: agenda, appointment_type: appointment_type,
                                                date: Date.civil(2022, 5, 26),
                                                starting_time: new_time_for(13, 0))
    slot2 = create(:slot, agenda: agenda, appointment_type: appointment_type,
                          date: Date.civil(2022, 6, 27),
                          starting_time: new_time_for(15, 30))

    convict = create :convict
    create :areas_convicts_mapping, convict: convict, area: user.organization.departments.first

    appointment1 = build :appointment, :with_notifications, convict: convict, slot: slot1
    appointment2 = build :appointment, :with_notifications, convict: convict, slot: slot2
    appointment1.save validate: false
    appointment2.save validate: false

    appointment2.book
  end

  it 'should display a flash alert and link to a page which lists only uninformed appointments' do
    visit home_path

    expect(page).to have_content("Attention, il y a 50% de rendez-vous dont le statut n'est pas complété")

    within first('p.warning', text: 'Attention') do
      click_on('Cliquez-ici')
    end

    expect(page).to have_content(Date.civil(2022, 6, 27))
    expect(page).to have_content('15:30')
  end
end
