require 'rails_helper'

RSpec.describe UserAlert, type: :model do
  describe 'links_point_to_authorized_domains' do
    it 'allows content without any link' do
      user_alert = build(:user_alert, content: 'Contenu de test sans lien')

      expect(user_alert).to be_valid
    end

    it 'allows a link to a gouv.fr subdomain' do
      user_alert = build(:user_alert, content: '<a href="https://exemple.gouv.fr/page">lien</a>')

      expect(user_alert).to be_valid
    end

    it 'rejects a link to an external domain' do
      user_alert = build(:user_alert, content: '<a href="https://evil.com/phishing">lien</a>')

      expect(user_alert).not_to be_valid
      expect(user_alert.errors[:content].join).to include('evil.com')
    end

    it 'strips a javascript: link before it reaches the domain check' do
      # ActionText's own sanitizer already strips non-http(s) href schemes on render,
      # so nothing dangerous is left by the time our validation runs.
      user_alert = build(:user_alert, content: '<a href="javascript:alert(1)">lien</a>')

      expect(user_alert).to be_valid
      expect(user_alert.content.body.to_s).not_to include('javascript:')
    end

    it 'adds rel="noopener noreferrer" to authorized links on save' do
      user_alert = create(:user_alert, content: '<a href="https://exemple.gouv.fr/page">lien</a>')

      expect(user_alert.content.body.to_s).to include('rel="noopener noreferrer"')
    end
  end
end
