require 'rails_helper'

RSpec.describe DeviseInvitable::Mailer, type: :mailer do
  describe 'deliver' do
    let(:user) { FactoryBot.create(:user, email: 'agent@example.com', first_name: 'Super Agent') }
    let(:mail) { user.invite! }

    it 'renders the headers' do
      expect(mail.subject).to eq('Vous avez reçu une invitation de Mon Suivi Justice')
      expect(mail.to).to eq(['agent@example.com'])
      expect(mail.from).to eq(['contact@mon-suivi-justice.beta.gouv.fr'])
    end

    # rubocop:disable Layout/LineLength
    it 'renders the body' do
      expect(mail.body.encoded).to match('Bonjour Super Agent')
      expect(mail.body.encoded).to match("Pour activer votre compte et commencer =C3=A0 utiliser Mon Suivi Justice,=\n veuillez copier-coller le lien suivant dans le navigateur Chrome ou Fire=\nfox :")
      expect(mail.body.encoded).to match("Un guide d=E2=80=99utilisation est disponible en ligne afin de vous ac=\ncompagner dans la prise en main de Mon Suivi Justice : https://documentat=\nion.mon-suivi-justice.beta.gouv.fr/. Ce document est en cours de co-const=\nruction avec les utilisateurs.")
    end
    # rubocop:enable Layout/LineLength
  end
end
