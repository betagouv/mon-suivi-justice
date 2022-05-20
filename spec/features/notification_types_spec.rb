require 'rails_helper'

RSpec.feature 'NotificationType', type: :feature, focus: true do
  before do
    create_admin_user_and_login
  end

  describe 'update' do
    it 'updates a default template set' do

    end

    it 'updates an organization specific template set' do

    end
  end

  xdescribe 'creation' do
    it 'creates a batch of notification_type after organization creation' do

    end
  end
end
