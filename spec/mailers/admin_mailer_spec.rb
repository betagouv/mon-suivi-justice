require 'rails_helper'

RSpec.describe AdminMailer, type: :mailer do
  describe '#warn_link_mobility_for_misrouted_notifications' do
    let(:phones) { ['+33611111111', '+33622222222'] }
    let(:mail) { described_class.with(phones: phones).warn_link_mobility_for_misrouted_notifications }

    it 'rend les bons destinataires' do
      expect(mail.to).to eq(['support.fr@linkmobility.com'])
      expect(mail.cc).to eq(['matthieu.faugere@beta.gouv.fr', 'damien.le-thiec@beta.gouv.fr',
                             'cyrille.corbin@justice.gouv.fr'])
    end

    it 'a le bon sujet' do
      expect(mail.subject).to eq('Mon Suivi Justice - Liste des numéros non routés')
    end

    it 'inclut les numéros de téléphone dans le corps du mail' do
      expect(mail.body.encoded).to include('+33611111111')
      expect(mail.body.encoded).to include('+33622222222')
    end
  end
end
