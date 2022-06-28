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
    @user = create_admin_user_and_login

    place = create :place, organization: @user.organization
    @agenda = create :agenda, place: place

    slot1 = create(:slot, :without_validations, agenda: @agenda,
                                                date: Date.civil(2022, 6, 27),
                                                starting_time: new_time_for(13, 0))
    slot2 = create(:slot, agenda: @agenda,
                          date: Date.civil(2022, 6, 27),
                          starting_time: new_time_for(15, 30))

    convict = create(:convict)
    create :areas_convicts_mapping, convict: convict, area: @user.organization.departments.first

    @appointment1 = build(:appointment, convict: convict, slot: slot1, state: 'fulfiled')
    @appointment2 = build(:appointment, convict: convict, slot: slot2, state: 'booked')
    @appointment1.save(validate: false)
    @appointment2.save(validate: false)
  end

  it 'should display a flash alert if uninformed appointments percentage is above 20' do
    visit home_path

    expect(page).to have_content("Attention, il y a 50% de rendez-vous dont le statut n'est pas complété")
  end

  it ''
end
