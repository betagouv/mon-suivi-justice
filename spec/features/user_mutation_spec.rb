# spec/features/user_mutation_spec.rb

require 'rails_helper'

RSpec.feature 'UserMutation', type: :feature do
  let(:existing_user) do
    create(:user, email: 'existing_user@example.com', organization: create(:organization, name: 'Old Organization'))
  end

  before do
    existing_user
    past_appointment = build(:appointment, user: existing_user,
                                           slot: create(:slot, date: next_valid_day(date: Date.today - 20.days)))
    past_appointment.save(validate: false)

    create(:appointment, user: existing_user, slot: create(:slot, date: next_valid_day(date: Date.today + 20.days)))
    create(:convict, user: existing_user)
  end

  describe 'local admin invites a user from another organization', logged_in_as: 'local_admin', js: true do
    it 'can invite a user from another organization' do
      visit new_user_invitation_path

      fill_in 'Email', with: 'existing_user@example.com'

      click_button 'Envoyer invitation'

      expect(page).to have_content("est déjà pris par un agent d'un autre service")
      expect(page).to have_link('Muter l’agent dans mon service')

      accept_alert do
        click_link 'Muter l’agent dans mon service'
      end

      expect(page).to have_current_path(user_path(existing_user))
      expect(page).to have_content('L’agent a bien été muté dans votre service')
      expect(existing_user.reload.organization).to eq(@user.organization)

      # Check removal of assigned convicts and future appointments
      future_appointments = existing_user.appointments.joins(:slot).where('slots.date > ?', Date.today)
      expect(future_appointments).to be_empty
      expect(existing_user.convicts).to be_empty
    end
  end
end
