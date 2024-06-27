require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '#notify_local_admins_of_mutation' do
    let(:headquarter) { create(:headquarter) }
    let(:old_organization) { create(:organization, headquarter:) }
    let(:new_organization) { create(:organization) }
    let(:other_organization) { create(:organization) }
    let(:user) { create(:user, organization: new_organization) }
    let(:local_admin) { create(:user, role: 'local_admin', organization: other_organization) }
    let(:send_email) { -> { UserMailer.notify_local_admins_of_mutation(user, old_organization).deliver_now } }

    context 'when there are local admins in the old organization' do
      before do
        local_admin.update(organization: old_organization, headquarter:)
        send_email.call
      end

      it 'sends an email to the local admins of the old organization' do
        expect(ActionMailer::Base.deliveries.first.to).to eq([local_admin.email])
      end
    end

    context 'when there are no local admins in the old organization but there are in the headquarter' do
      before do
        local_admin.update(headquarter:)
        send_email.call
      end

      it 'sends an email to the local admins of the headquarter' do
        expect(ActionMailer::Base.deliveries.first.to).to eq([local_admin.email])
      end
    end

    context 'when there are no local admins in either the old organization or the headquarter' do
      before do
        send_email.call
      end

      it 'does not send an email' do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end
end
