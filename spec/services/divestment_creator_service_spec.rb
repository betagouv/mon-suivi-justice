# spec/services/divestment_creator_spec.rb
require 'rails_helper'

RSpec.describe DivestmentCreatorService do
  let(:user) { create(:user, :in_organization, role: 'cpip') }
  let(:convict) { create(:convict) }
  let(:unsaved_divestment) { create(:divestment, convict:, user:, organization: user.organization) }

  subject(:service) { DivestmentCreatorService.new(convict, user, unsaved_divestment) }

  describe '#call' do
    before do
      allow(convict).to receive(:discarded?).and_return(false)
      allow(convict).to receive(:last_appointment_at_least_6_months_old?).and_return(false)
    end

    context 'when convict is linked to 1 antenne and need to be moved to another one' do
      let(:spip1) { create(:organization, organization_type: :spip, name: 'old spip') }
      let(:spip2) { create(:organization, organization_type: :spip, name: 'new spip') }
      let!(:tj) do
        tj = build(:organization, organization_type: :tj, name: 'same tj')
        tj.spips = [spip1, spip2]
        tj.save
        tj
      end

      let!(:local_admin_spip1) { create(:user, role: 'local_admin', organization: spip1) }
      let!(:local_admin_tj) { create(:user, role: 'local_admin', organization: tj) }
      let(:user) { create(:user, role: 'cpip', organization: spip2) }
      let(:convict) { create(:convict, organizations: [spip1, tj]) }

      it 'creates organization divestments with pending state' do
        spip1.update(tjs: [tj])
        spip2.update(tjs: [tj])
        create_appointment(convict, spip1, date: 1.month.ago)
        service.call
        unsaved_divestment.reload
        od_spip = unsaved_divestment.organization_divestments.find_by(organization: spip1)
        expect(unsaved_divestment.state).to eq('pending')
        expect(od_spip.state).to eq('pending')
      end
    end
    context 'when organizations have local admins' do
      before do
        create_list(:organization, 2, convicts: [convict])
      end

      it 'creates organization divestments with pending state' do
        convict.reload
        convict.organizations.each do |org|
          create(:user, role: 'local_admin', organization: org)
        end

        expect { service.call }.to change { OrganizationDivestment.where(state: 'pending').count }.by(3)
      end
    end

    context 'when organizations do not have divestment roles' do
      before do
        create_list(:organization, 2, convicts: [convict])
      end

      it 'creates organization divestments with ignored state' do
        convict.reload
        expect { service.call }.to change { OrganizationDivestment.where(state: 'ignored').count }.by(3)
      end
    end

    context 'when organizations are SPIP and TJS' do
      let(:tj) { create(:organization, organization_type: :tj, name: 'old tj') }
      let(:spip) do
        spip = build(:organization, organization_type: :spip, name: 'old spip')
        spip.tjs = [tj]
        spip.save
        spip
      end
      let!(:admin_spip) { create(:user, role: 'local_admin', organization: spip) }
      let(:convict) { create(:convict, organizations: [tj, spip]) }

      context 'when the TJ has a local admin' do
        let!(:admin_tj) { create(:user, role: 'local_admin', organization: tj) }

        it 'creates organization divestments with auto_accepted state for spip if tj' do
          service.call
          expect(service.divestment.organization_divestments.count).to eq(2)
          expect(service.divestment.state).to eq('pending')
          expect(service.divestment.organization_divestments.find_by(organization: spip).state).to eq('auto_accepted')
          expect(service.divestment.organization_divestments.find_by(organization: tj).state).to eq('pending')
        end
      end

      context 'when the TJ does not have divestment roles' do
        it 'creates organization divestments with pending state for spip if tj and tj has local admin' do
          service.call
          expect(service.divestment.organization_divestments.count).to eq(2)
          expect(service.divestment.state).to eq('pending')
          expect(service.divestment.organization_divestments.find_by(organization: spip).state).to eq('pending')
          expect(service.divestment.organization_divestments.find_by(organization: tj).state).to eq('ignored')
        end
      end
    end

    context 'when the convict is discarded' do
      before do
        allow(convict).to receive(:discarded?).and_return(true)
      end

      it 'sets divestment state to accepted' do
        service.call
        divestment = Divestment.last
        expect(divestment.state).to eq('auto_accepted')
        convict.reload
        expect(convict.organizations).to match_array([user.organization])
      end
    end

    context 'when the last appointment is at least 6 months old' do
      before do
        allow(convict).to receive(:discarded?).and_return(false)
        allow(convict).to receive(:last_appointment_at_least_6_months_old?).and_return(true)
      end
      it 'sets divestment state to accepted and update convict orgas' do
        service.call
        divestment = Divestment.last
        expect(divestment.state).to eq('auto_accepted')
        convict.reload
        expect(convict.organizations).to match_array([user.organization])
      end

      context 'invalid convict' do
        let(:convict) do
          c = build(:convict, appi_uuid: 'abc')
          c.save(validate: false)
          c
        end

        it 'sets divestment state to pending and does not update convict orgas' do
          convict_organizations = [*convict.organizations]
          service.call
          divestment = Divestment.last
          expect(divestment.state).to eq('pending')
          convict.reload
          expect(convict.organizations).to match_array(convict_organizations)
        end
      end
    end

    context 'when the convict is not discarded and last appointment is less than 6 months old' do
      before do
        allow(convict).to receive(:discarded?).and_return(false)
        allow(convict).to receive(:last_appointment_at_least_6_months_old?).and_return(false)
      end

      it 'sets divestment state to pending' do
        convict_organizations = [*convict.organizations]
        service.call
        divestment = Divestment.last
        expect(divestment.state).to eq('pending')
        convict.reload
        expect(convict.organizations).to match_array(convict_organizations)
      end

      context 'user is bex' do
        let(:user) { create(:user, :in_organization, type: :tj, role: 'bex') }
        it 'add user organization to current convict organizations' do
          convict_organizations = [*convict.organizations]
          service.call
          divestment = Divestment.last
          expect(divestment.state).to eq('pending')

          convict.reload
          expect(convict.organizations).to match_array(convict_organizations + [user.organization])
        end

        context 'invalid convict' do
          let(:convict) do
            c = build(:convict, appi_uuid: 'abc')
            c.save(validate: false)
            c
          end
          it 'does not add user organization to current convict organizations' do
            convict_organizations = [*convict.organizations]
            service.call
            divestment = Divestment.last
            expect(divestment.state).to eq('pending')

            convict.reload
            expect(convict_organizations).to match_array(convict.organizations)
          end
        end
      end
    end
  end
end
