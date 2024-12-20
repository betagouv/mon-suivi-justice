require 'rails_helper'

RSpec.describe AdminMailer, type: :mailer do
  describe '#notifications_problems' do
    let(:to_reschedule_ids) { [1, 2, 3] }
    let(:stucked_ids) { [4, 5, 6] }
    let(:mail) { described_class.notifications_problems(stucked_ids).deliver_now }

    it 'renders the headers' do
      dev_emails = ENV.fetch('DEV_EMAILS').split(',')
      expect(mail.subject).to eq('Notifications remises dans la queue')
      expect(mail.to).to eq(dev_emails)
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Notifications problématiques')
      stucked_ids.each do |id|
        expect(mail.body.encoded).to match("ID: #{id}")
      end
    end
  end
end
