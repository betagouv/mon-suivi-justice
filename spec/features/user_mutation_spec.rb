# spec/features/user_mutation_spec.rb

require 'rails_helper'

RSpec.feature 'UserMutation', type: :feature do
  let(:existing_user) do
    create(:user, email: 'existing_user@example.com', organization: create(:organization, name: 'Old Organization'))
  end

  let(:slot) { create_ignore_validation(:slot, date: next_valid_day(date: Date.today - 20.days)) }
  before do
    existing_user # create the existing user
    past_appointment = build(:appointment, user: existing_user,
                                           slot:)
    past_appointment.save(validate: false)

    create(:appointment, user: existing_user, slot: create(:slot, date: next_valid_day(date: Date.today + 20.days)))
    create(:convict, user: existing_user)
    create(:user, email: 'local_admin@example.com', organization: existing_user.organization, role: 'local_admin')

    allow(UserMailer).to receive(:notify_mutation).and_call_original
    allow(UserMailer).to receive(:notify_local_admins_of_mutation).and_call_original

    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActionMailer::Base.deliveries.clear
  end

  describe 'local admin invites a user from another organization', logged_in_as: 'local_admin_spip', js: true do
    it 'can invite a user from another organization' do
      visit new_user_invitation_path

      fill_in 'Email', with: 'existing_user@example.com'

      click_button 'Envoyer invitation'

      expect(page).to have_content("est déjà pris par un agent d'un autre service")
      expect(page).to have_link('Muter l\'agent dans mon service')

      old_organization = existing_user.organization

      accept_alert do
        click_link 'Muter l\'agent dans mon service'
      end

      expect(page).to have_current_path(user_path(existing_user))
      expect(page).to have_content("L'agent a bien été muté dans votre service")
      expect(existing_user.reload.organization).to eq(@user.organization)

      # Check removal of assigned convicts and future appointments
      future_appointments = existing_user.appointments.joins(:slot).where('slots.date > ?', Date.today)
      expect(future_appointments).to be_empty
      expect(existing_user.convicts).to be_empty

      expect(UserMailer).to have_received(:notify_mutation).with(existing_user)
      expect(UserMailer).to have_received(:notify_local_admins_of_mutation).with(existing_user,
                                                                                 old_organization)

      perform_enqueued_jobs

      emails = ActionMailer::Base.deliveries
      expect(emails.first.to).to include('existing_user@example.com')
      expect(emails.second.to).to include('local_admin@example.com')
    end
  end
end
