require 'rails_helper'

RSpec.describe Cleanup do
  describe 'DeleteUnactiveConvicts' do
    describe 'call' do
      let!(:inactive_old_convict) { create(:convict, created_at: 20.months.ago) }
      let!(:active_old_convict) { create(:convict, created_at: 19.months.ago) }
      let!(:active_recent_convict) { create(:convict, created_at: 17.months.ago) }
      let!(:inactive_recent_convict) { create(:convict, created_at: 17.months.ago) }

      let!(:old_slot) { create(:slot, :without_validations, date: 19.months.ago) }
      let!(:new_slot) { create(:slot, :without_validations, date: 16.months.ago) }
      let!(:new_slot2) { create(:slot, :without_validations, date: 6.months.ago) }

      let!(:old_appointment) { create(:appointment, :skip_validate, slot: old_slot, convict: inactive_old_convict) }
      let!(:new_appointment) { create(:appointment, :skip_validate, slot: new_slot, convict: active_recent_convict) }
      let!(:new_appointment2) { create(:appointment, :skip_validate, slot: new_slot2, convict: active_old_convict) }
      before do
        # Call the service once before all tests
        Cleanup::DeleteUnactiveConvicts.new.call
      end

      it 'ensures active old convict still exists' do
        expect(Convict.exists?(active_old_convict.id)).to be true
      end

      it 'ensures inactive old convict does not exist' do
        expect(Convict.exists?(inactive_old_convict.id)).to be false
        expect(Appointment.exists?(old_appointment.id)).to be false
      end

      it 'ensures active recent convict still exists' do
        expect(Convict.exists?(active_recent_convict.id)).to be true
      end

      it 'ensures inactive recent convict still exists' do
        expect(Convict.exists?(inactive_recent_convict.id)).to be true
      end
    end
  end
  describe 'ArchiveUnactiveConvicts' do
    describe 'call' do
      let!(:inactive_old_convict) { create(:convict, created_at: 14.months.ago) }
      let!(:active_old_convict) { create(:convict, created_at: 13.months.ago) }
      let!(:active_recent_convict) { create(:convict, created_at: 11.months.ago) }
      let!(:inactive_recent_convict) { create(:convict, created_at: 11.months.ago) }

      let!(:old_slot) { create(:slot, :without_validations, date: 13.months.ago) }
      let!(:new_slot) { create(:slot, :without_validations, date: 10.months.ago) }
      let!(:new_slot2) { create(:slot, :without_validations, date: 6.months.ago) }

      let!(:old_appointment) { create(:appointment, :skip_validate, slot: old_slot, convict: inactive_old_convict) }
      let!(:new_appointment) { create(:appointment, :skip_validate, slot: new_slot, convict: active_recent_convict) }
      let!(:new_appointment2) { create(:appointment, :skip_validate, slot: new_slot2, convict: active_old_convict) }
      before do
        # Call the service once before all tests
        Cleanup::ArchiveUnactiveConvicts.new.call
      end

      it 'ensures active old convict is not actived' do
        expect(active_old_convict.discarded?).to be false
      end

      it 'ensures inactive old convict is archived' do
        history_items = HistoryItem.where(convict: inactive_old_convict, category: %w[convict])
                                .order(created_at: :desc)
        inactive_old_convict.reload
        expect(inactive_old_convict.discarded?).to be true
        expect(history_items.first.event).to eq('archive_convict')
      end

      it 'ensures active recent convict is not archived' do
        expect(active_recent_convict.discarded?).to be false
      end

      it 'ensures inactive recent convict is not archived' do
        expect(inactive_recent_convict.discarded?).to be false
      end
    end
  end
end
