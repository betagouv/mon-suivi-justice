require 'rails_helper'

RSpec.describe ConvictsController, type: :controller do
  describe '#divestment_button_checks' do
    let(:user) { create(:user, :in_organization) }
    let(:duplicate_convict) { create(:convict) }
    let(:current_organization) { user.organization }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:current_organization).and_return(current_organization)
      controller.instance_variable_set(:@duplicate_convict, duplicate_convict)
    end

    context 'when duplicate convict is under the current organization' do
      before do
        duplicate_convict.organizations << current_organization
      end

      it 'does not show the divestment button and sets an alert' do
        controller.send(:divestment_button_checks)
        expect(controller.instance_variable_get(:@show_divestment_button)).to be_falsey
        expect(controller.instance_variable_get(:@duplicate_alert)).to include('votre propre service')
      end
    end

    context 'when duplicate convict is under a different organization' do
      let(:other_organization) { create(:organization) }

      before do
        duplicate_convict.organizations << other_organization
        controller.instance_variable_set(:@pending_divestment, nil)
        controller.instance_variable_set(:@future_appointments, [])
        controller.send(:divestment_button_checks)
      end

      it 'shows the divestment button' do
        expect(controller.instance_variable_get(:@show_divestment_button)).to be_truthy
      end

      it 'sets the correct duplicate alert message' do
        alert_message = controller.instance_variable_get(:@duplicate_alert)
        expect(alert_message).to include(other_organization.name)
        expect(alert_message).to include('suivi par')
      end

      context 'with pending divestment for duplicate convict' do
        let(:other_org_user) { create(:user, :in_organization, role: 'local_admin') }
        let(:pending_divestment) do
          create(:divestment, user: other_org_user, state: 'pending', convict: duplicate_convict)
        end

        before do
          controller.instance_variable_set(:@pending_divestment, pending_divestment)
          controller.send(:divestment_button_checks)
        end

        it 'does not show the divestment button' do
          expect(controller.instance_variable_get(:@show_divestment_button)).to be_falsey
        end

        it 'sets a notice about the pending divestment' do
          notice = controller.instance_variable_get(:@show_pending_divestment_notice)
          expect(notice).to include("déjà l'objet d'une demande de dessaisissement")
          expect(notice).to include(pending_divestment.organization.name)
        end
      end
    end

    context 'with future appointments for duplicate convict' do
      let(:other_organization) { create(:organization) }
      let(:agenda) { create(:agenda, place: create(:place, organization: other_organization)) }
      let(:appointment_type) { create(:appointment_type, :with_notification_types, organization: other_organization) }
      let(:future_slot) do
        create(:slot, agenda:, date: next_valid_day(date: Date.today), starting_time: new_time_for(15, 30),
                      appointment_type:)
      end

      before do
        create(:appointment, convict: duplicate_convict, slot: future_slot, state: 'booked')
        controller.instance_variable_set(:@future_appointments,
                                         duplicate_convict.appointments.where('date >= ?', Date.today))
        controller.send(:divestment_button_checks)
      end

      it 'does not show the divestment button' do
        expect(controller.instance_variable_get(:@show_divestment_button)).to be_falsey
      end
    end
  end
end
