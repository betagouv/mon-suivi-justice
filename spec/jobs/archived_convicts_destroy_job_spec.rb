require 'rails_helper'

RSpec.describe ArchivedConvictsDestroyJob, type: :job do
  describe '#perform_later' do
    let(:tested_method) { ArchivedConvictsDestroyJob.perform_later }

    it 'queues the job' do
      tested_method
      expect(ArchivedConvictsDestroyJob).to have_been_enqueued.once
    end
  end

  describe '#perform' do
    before do
      Timecop.freeze(Time.zone.parse('2021-02-02')) do
        @convict1 = create :convict
        @convict2 = create :convict
        @convict3 = create :convict
        @convict1.discard
      end
      Timecop.freeze(Time.zone.parse('2021-04-04')) do
        @convict2.discard
      end
      Timecop.freeze(Time.zone.parse('2021-09-09')) do
        ArchivedConvictsDestroyJob.new.perform
      end
    end

    it 'delete fully convict deleted 7 months ago' do
      expect(Convict.exists?(id: @convict1.id)).to be false
    end
    it 'does not delete fully convict deleted 5 months ago' do
      expect(Convict.exists?(id: @convict2.id)).to be true
    end
    it 'does not delete fully convict not deleted' do
      expect(Convict.exists?(id: @convict3.id)).to be true
    end
  end
end
