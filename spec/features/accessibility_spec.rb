require 'rails_helper'

RSpec.feature 'Accessibility', type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:convict) { create(:convict, creating_organization: organization) }
  let(:appointment) { create(:appointment, organization: organization, convict: convict) }
  let(:appointment_type) { create(:appointment_type, organization: organization) }
  let(:slot) { create(:slot, organization: organization) }
  let(:slot_type) { create(:slot_type, organization: organization) }
  let(:agenda) { create(:agenda, organization: organization) }
  let(:place) { create(:place, organization: organization) }
  let(:notification) { create(:notification, organization: organization, appointment: appointment) }
  let(:user_alert) { create(:user_alert, organization: organization) }

  describe 'devise/sessions#new', js: true do
    it 'is accessible' do
      visit new_user_session_path
      expect(page).to be_axe_clean
    end
  end

  describe 'devise/passwords#new', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit new_user_password_path
      expect(page).to be_axe_clean
    end
  end

  describe 'devise/passwords#edit', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit edit_user_password_path
      expect(page).to be_axe_clean
    end
  end

  describe 'invitations#edit', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit accept_user_invitation_path
      expect(page).to be_axe_clean
    end
  end
  
  describe 'invitations#new', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit new_user_invitation_path
      expect(page).to be_axe_clean
    end
  end

  describe 'organizations#index', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit organizations_path
      expect(page).to be_axe_clean
    end
  end

  describe 'organizations#new', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit new_organization_path
      expect(page).to be_axe_clean
    end
  end

  describe 'organizations#edit', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit edit_organization_path(organization)
      expect(page).to be_axe_clean
    end
  end

  describe 'organizations#show', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit organization_path(organization)
      expect(page).to be_axe_clean
    end
  end

  describe 'users#invitation_link', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit user_invitation_link_path(user)
      expect(page).to be_axe_clean
    end
  end

  describe 'users#reset_pwd_link', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit user_reset_pwd_link_path(user)
      expect(page).to be_axe_clean
    end
  end

  describe 'users#index', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit users_path
      expect(page).to be_axe_clean
    end
  end

  describe 'users#new', logged_in_as: 'admin', js: true do
    it 'is accessible' do
     visit new_user_path
      expect(page).to be_axe_clean
    end
  end

  describe 'users#edit', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit edit_user_path(user)
      expect(page).to be_axe_clean
    end
  end

  describe 'users#show', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit user_path(user)
      expect(page).to be_axe_clean
    end
  end

  describe 'users/appointments#index', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit user_appointments_path
      expect(page).to be_axe_clean
    end
  end

  describe 'users/notifications#index', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit user_user_notifications_path
      expect(page).to be_axe_clean
    end
  end

  describe 'convicts#index', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit convicts_path
      expect(page).to be_axe_clean
    end
  end

  describe 'convicts#new', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit new_convict_path
      expect(page).to be_axe_clean
    end
  end

  describe 'convicts#edit', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit edit_convict_path(convict)
      expect(page).to be_axe_clean
    end
  end

  describe 'convicts#show', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit convict_path(convict)
      expect(page).to be_axe_clean
    end
  end

  describe 'places#index', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit places_path
      expect(page).to be_axe_clean
    end
  end

  describe 'places#new', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit new_place_path
      expect(page).to be_axe_clean
    end
  end

  describe 'places#edit', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit edit_place_path(place)
      expect(page).to be_axe_clean
    end
  end

  describe 'places#show', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit place_path(place)
      expect(page).to be_axe_clean
    end
  end

  describe 'appointment_types#index', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit appointment_types_path
      expect(page).to be_axe_clean
    end
  end

  describe 'appointment_types#new', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit new_appointment_type_path
      expect(page).to be_axe_clean
    end
  end

  describe 'appointment_types#edit', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit edit_appointment_type_path(appointment_type)
      expect(page).to be_axe_clean
    end
  end

  describe 'appointment_types#show', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit appointment_type_path(appointment_type)
      expect(page).to be_axe_clean
    end
  end

  describe 'slots#index', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit slots_path
      expect(page).to be_axe_clean
    end
  end

  describe 'slots#new', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit new_slot_path
      expect(page).to be_axe_clean
    end
  end

  describe 'slots#edit', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit edit_slot_path(slot)
      expect(page).to be_axe_clean
    end
  end

  describe 'slots#show', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit slot_path(slot)
      expect(page).to be_axe_clean
    end
  end

  describe 'slots_batches#new', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit new_slots_batch_path  
      expect(page).to be_axe_clean
    end 
  end

  describe 'slot_types#index', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit agenda_slot_types_path(agenda)
      expect(page).to be_axe_clean
    end
  end

  describe 'appointments_reschedules#new', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit new_appointment_reschedule_path(appointment)
      expect(page).to be_axe_clean
    end
  end

  describe 'appointments#index', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit appointments_path
      expect(page).to be_axe_clean
    end
  end

  describe 'appointments#new', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit new_appointment_path
      expect(page).to be_axe_clean
    end
  end

  describe 'appointments#edit', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit edit_appointment_path(appointment)
      expect(page).to be_axe_clean
    end
  end
  
  describe 'appointments#show', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit appointment_path(appointment)
      expect(page).to be_axe_clean
    end
  end
  
  
  describe 'bex#agenda_jap', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit agenda_jap_path
      expect(page).to be_axe_clean
    end
  end
  
  describe 'bex#agenda_spip', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit agenda_spip_path
      expect(page).to be_axe_clean
    end
  end
  
  describe 'bex#agenda_sap_ddse', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit agenda_sap_ddse_path
      expect(page).to be_axe_clean
    end
  end

  describe 'home#home', logged_in_ass: 'admin', js: true do
    it 'is accessible' do  
      visit home_path
      expect(page).to be_axe_clean
    end
  end
  
  describe 'steerings#show', logged_in_as: 'admin', js: true do
    it 'is accsesible' do
      visit steering_path
      expect(page).to be_axe_clean
    end
  end

  describe 'steerings#user_app_stats', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit steering_user_app_path
      expect(page).to be_axe_clean
    end
  end

  describe 'steerings#convict_app_stats', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit steering_convict_app_path
      expect(page).to be_axe_clean
    end
  end

  describe 'steerings#sda_stats', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit steering_sda_path
      expect(page).to be_axe_clean
    end
  end

  describe 'user_user_alerts#index', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit user_user_alerts_path
      expect(page).to be_axe_clean
    end
  end

  describe 'user_user_alerts#new', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit new_user_user_alert_path
      expect(page).to be_axe_clean
    end
  end

  describe 'user_user_alerts#edit', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit edit_user_user_alert_path(user_alert)
      expect(page).to be_axe_clean
    end
  end

  describe 'user_user_alerts#show', logged_in_as: 'admin', js: true do
    it 'is accessible' do
      visit user_user_alert_path(user_alert)
      expect(page).to be_axe_clean
    end
  end
end