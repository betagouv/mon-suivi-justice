require 'rails_helper'

RSpec.describe Cleanup do
  describe 'DeleteUnactiveConvicts' do
    describe 'call' do
      before(:all) do
        # Setup data here
        @inactive_old_convict = create(:convict, created_at: 20.months.ago)
        @active_old_convict = create(:convict, created_at: 19.months.ago)
        @active_recent_convict = create(:convict, created_at: 17.months.ago)
        @inactive_recent_convict = create(:convict, created_at: 17.months.ago)

        @old_slot = create(:slot, :without_validations, date: 19.months.ago)
        @new_slot = create(:slot, :without_validations, date: 16.months.ago)
        @new_slot2 = create(:slot, :without_validations, date: 6.months.ago)

        @old_appointment = create(:appointment, :skip_validate, slot: @old_slot, convict: @inactive_old_convict)
        @new_appointment = create(:appointment, :skip_validate, slot: @new_slot, convict: @active_recent_convict)
        @new_appointment2 = create(:appointment, :skip_validate, slot: @new_slot2, convict: @active_old_convict)

        # Call the service once before all tests
        Cleanup::DeleteUnactiveConvicts.new.call
      end

      it 'ensures active old convict still exists' do
        expect(Convict.exists?(@active_old_convict.id)).to be true
      end

      it 'ensures inactive old convict does not exist' do
        expect(Convict.exists?(@inactive_old_convict.id)).to be false
        expect(Appointment.exists?(@old_appointment.id)).to be false
      end

      it 'ensures active recent convict still exists' do
        expect(Convict.exists?(@active_recent_convict.id)).to be true
      end

      it 'ensures inactive recent convict still exists' do
        expect(Convict.exists?(@inactive_recent_convict.id)).to be true
      end
    end
  end
end
