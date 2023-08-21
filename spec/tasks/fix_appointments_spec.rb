require 'rails_helper'
require 'rake'

RSpec.describe 'appointments namespace rake tasks' do
  before :all do
    Rake.application.rake_require 'tasks/fix_appointments'
    Rake::Task.define_task(:environment)
  end

  describe 'update_state' do
    let(:today) { next_valid_day(date: Date.today) }

    let!(:organization) { create(:organization, name: 'Test Organization') }
    let!(:place) { create(:place, organization:) }
    let!(:agenda) { create(:agenda, name: 'Test Agenda', place:) }
    let!(:appointment_type) { create(:appointment_type) }
    let!(:convict) { create(:convict, organizations: [organization]) }
    let!(:notif_type) do
      create(:notification_type, appointment_type:, role: :summon, template: 'Blabla', is_default: true)
    end

    let!(:slot) do
      Slot.create!(date: today, starting_time: '10:00', appointment_type:, agenda:)
    end

    let!(:booked_appointment) do
      Appointment.create!(convict:, slot:, state: 'booked')
    end

    let!(:created_appointment_conflicting) do
      Appointment.create!(convict:, slot:, state: 'created', created_at: today)
    end

    let!(:created_appointment_non_conflicting) do
      slot_non_conflicting = Slot.create!(date: today, starting_time: '11:00', appointment_type:,
                                          agenda:)
      Appointment.create!(convict:, slot: slot_non_conflicting, state: 'created', created_at: today)
    end

    it 'should destroy conflicting appointments and book non-conflicting ones' do
      expect do
        Rake.application.invoke_task('appointments:update_state')
      end.to change { Appointment.count }.by(-1)

      # Assertions
      expect(Appointment.exists?(created_appointment_conflicting.id)).to be_falsey
      expect(created_appointment_non_conflicting.reload.state).to eq('booked')
    end

    # You can add more examples, for instance:
    # - When there are no appointments at all.
    # - When there are only booked appointments.
    # - When all appointments are non-conflicting.
  end
end
