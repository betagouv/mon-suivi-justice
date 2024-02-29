require 'rails_helper'

RSpec.describe AppiImportJob, type: :job do
  describe '#process_convict' do
    let(:target_organizations) { [create(:organization), create(:organization)] }
    let(:convict_hash) { { date_of_birth: '02/02/1987', appi_uuid: "2024#{Faker::Number.unique.number(digits: 8)}", first_name: 'Bob', last_name: 'Dupneu' } }
    let(:job) { AppiImportJob.new }

    before do
      job.instance_variable_set(:@import_errors, [])
      job.instance_variable_set(:@import_successes, [])
      job.instance_variable_set(:@import_update_successes, Hash.new { |hash, key| hash[key] = [] })
      job.instance_variable_set(:@import_update_failures, Hash.new { |hash, key| hash[key] = [] })
      job.instance_variable_set(:@calculated_organizations_names, [])
    end

    context 'when convict does not exist' do
      it 'creates a new convict' do
        expect { job.process_convict(convict_hash, target_organizations) }
          .to change { Convict.count }.by(1)
      end
    end

    context 'when convict already exists' do
      let!(:existing_organization) { create(:organization, organization_type: 'tj') }
      let!(:existing_convict) do
        create(:convict, organizations: [existing_organization], appi_uuid: convict_hash[:appi_uuid])
      end

      it 'does not create a new convict' do
        expect { job.process_convict(convict_hash, target_organizations) }
        .not_to(change { Convict.count })
      end

      context 'and already has one organization' do
        before do
          target_organizations.each do |org|
            org.linked_organizations << existing_convict.organizations.first
            org.organization_type = 'spip'
          end
        end

        it 'updates the convict with the target organizations' do
          expect { job.process_convict(convict_hash, target_organizations) }
            .to change { existing_convict.reload.organizations.count }.by(2)
        end
      end

      context 'and already belongs to more than one organization' do
        before do
          existing_convict.organizations << create_list(:organization, 2)
        end

        it 'does not update the convict with new organization' do
          expect { job.process_convict(convict_hash, target_organizations) }
            .not_to(change { existing_convict.reload.organizations.count })
        end
      end
    end
  end
end
