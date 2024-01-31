require 'rails_helper'

RSpec.describe DivestmentDecisionService do
  let(:user) { create(:user, :in_organization, role: 'cpip') }

  let(:other_organization) { create(:organization) }
  let(:other_user) { create(:user, organization: other_organization, role: 'cpip') }

  let(:duplicate_convict) { create(:convict, organizations: [other_organization]) }

  subject(:service) { DivestmentDecisionService.new(duplicate_convict, user.organization) }

  describe '#call' do
    context 'when convict is under the current organization' do
      before { duplicate_convict.organizations << user.organization }

      it 'does not show the divestment button and provides correct alert' do
        result = service.call
        expect(result[:show_button]).to be_falsey
        expect(result[:alert]).to include(duplicate_convict.name)
      end
    end

    context 'when convict is under a different organization' do
      it 'handles no pending divestments and no future appointments' do
        result = service.call
        expect(result[:show_button]).to be_truthy
      end

      context 'with a pending divestment' do
        let!(:pending_divestment) do
          create(:divestment, state: 'pending', convict: duplicate_convict, organization: other_organization,
                              user: other_user)
        end

        it 'does not show the divestment button and provides correct alert for pending divestment' do
          service = DivestmentDecisionService.new(duplicate_convict, user.organization)
          result = service.call
          expect(result[:show_button]).to be_falsey
          expect(result[:duplicate_alert_details]).to include('demande de dessaisissement')
        end
      end

      context 'with future appointments' do
        before do
          place = create :place, organization: other_user.organization
          agenda = create(:agenda, place:)

          apt_type = create(:appointment_type, :with_notification_types, organization: other_user.organization,
                                                                         name: 'Convocation de suivi SPIP')

          slot = create(:slot, :without_validations, agenda:,
                                                     date: next_valid_day(date: Date.tomorrow),
                                                     appointment_type: apt_type,
                                                     starting_time: new_time_for(13, 0))

          create(:appointment, :with_notifications,
                 convict: duplicate_convict,
                 state: 'booked',
                 slot:)
        end

        it 'does not show the divestment button and provides correct alert for pending divestment' do
          duplicate_convict.reload
          service = DivestmentDecisionService.new(duplicate_convict, user.organization)
          result = service.call
          expect(result[:show_button]).to be_falsey
          expect(result[:alert]).to include(duplicate_convict.name)
          expect(result[:alert]).to include(other_organization.name)
          expect(result[:alert]).to include(other_organization.places.first.phone)
        end
      end
    end
  end
end
