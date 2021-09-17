require 'rails_helper'

RSpec.feature 'SlotTypes', type: :feature do
  before do
    @agenda = create :agenda
    @appointment_type = create :appointment_type
  end

  scenario 'An agent can not access Slot types page' do
    login_user create(:user, role: :cpip)
    visit home_path
    expect(page).not_to have_content 'Créneaux Récurrent'
  end

  scenario 'An admin consults slot types' do
    create_admin_user_and_login
    create :slot_type, week_day: 'monday', starting_time: Time.zone.parse('2012-05-05 10:00:00'),
                       duration: 30, capacity: 1, appointment_type: @appointment_type, agenda: @agenda
    create :slot_type, week_day: 'tuesday', starting_time: Time.zone.parse('2012-05-05 16:00:00'),
                       duration: 60, capacity: 3, appointment_type: @appointment_type, agenda: @agenda
    visit home_path
    click_link 'Créneaux récurrents'
    expect(page).to have_content 'Type de RDV Agenda Jour Heure Durée Capacité'
    expect(page).to have_content "#{@appointment_type.name} #{@agenda.name} Lundi 10:00 30 1"
    expect(page).to have_content "#{@appointment_type.name} #{@agenda.name} Mardi 16:00 60 3"
  end

  scenario 'An admin edit a slot type' do
    create_admin_user_and_login
    create :slot_type, week_day: 'monday', starting_time: Time.zone.parse('2012-05-05 10:00:00'),
                       duration: 30, capacity: 1, appointment_type: @appointment_type, agenda: @agenda
    visit slot_types_path
    expect(page).to have_content "#{@appointment_type.name} #{@agenda.name} Lundi 10:00 30 1"
    click_link 'Modifier'
    select 'Jeudi', from: :slot_type_week_day
    fill_in :slot_type_duration, with: 23
    fill_in :slot_type_capacity, with: 6
    click_button 'Enregistrer'
    expect(page).to have_content "#{@appointment_type.name} #{@agenda.name} Jeudi 10:00 23 6"
  end

  scenario 'An admin delete a slot type' do
    create_admin_user_and_login
    create :slot_type, week_day: 'monday', starting_time: Time.zone.parse('2012-05-05 10:00:00'),
                       duration: 30, capacity: 1, appointment_type: @appointment_type, agenda: @agenda
    visit slot_types_path
    expect(page).to have_content "#{@appointment_type.name} #{@agenda.name} Lundi 10:00 30 1"
    expect { click_link 'Supprimer' }.to change(SlotType, :count).from(1).to(0)
    expect(page).not_to have_content "#{@appointment_type.name} #{@agenda.name} Jeudi 15:25 23 6"
  end
end
