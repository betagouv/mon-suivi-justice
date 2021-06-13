require 'rails_helper'

RSpec.feature 'Notifications', type: :feature, focus: true do
  before do
    create_admin_user_and_login
  end

  # describe 'index' do
  #   before do
  #     create(:notification, name: '1er rdv Spip')
  #     create(:notification, name: 'Spip 83')
  #
  #     visit notifications_path
  #   end
  #
  #   it 'lists all notifications' do
  #     expect(page).to have_content('Spip 78')
  #     expect(page).to have_content('Spip 83')
  #   end
  #
  #   it 'allows to delete notification' do
  #     within first('.places-item-container') do
  #       expect { click_link('Supprimer') }.to change { Notification.count }.by(-1)
  #     end
  #   end
  # end
  #
  # describe 'creation' do
  #   it 'works' do
  #   end
  # end
end
