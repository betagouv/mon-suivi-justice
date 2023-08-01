require 'rails_helper'

RSpec.describe DeviseInvitable::Mailer, type: :mailer do
  describe 'deliver' do
    let(:organization) { create(:organization, name: 'Organisation de test') }
    let(:user) { create(:user, email: 'agent@example.com', first_name: 'Super Agent', organization:) }
    let(:mail) { user.invite! }

    it 'renders the headers' do
      expect(mail.subject).to eq('Vous avez reçu une invitation de Mon Suivi Justice')
      expect(mail.to).to eq(['agent@example.com'])
      expect(mail.from).to eq(['support@mon-suivi-justice.beta.gouv.fr'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Bonjour Super Agent')
      expect(mail.body.encoded).to match('Pour activer votre compte et commencer =C3=A0 utiliser Mon Suivi Justice,')
      expect(mail.body.encoded).to match('veuillez copier-coller le lien suivant dans le navigateur Edge :')
    end
  end
end
