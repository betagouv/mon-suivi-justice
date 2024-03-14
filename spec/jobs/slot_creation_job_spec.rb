require 'rails_helper'

RSpec.describe SlotCreationJob, type: :job do
  describe '#perform_later' do
    let(:tested_method) { SlotCreationJob.perform_later }

    it 'queues the job' do
      tested_method
      expect(SlotCreationJob).to have_been_enqueued.once
    end
  end

  describe '#perform' do
    before do
      Timecop.freeze(Time.zone.parse('2021-05-03'))
      allow(SlotFactory).to receive(:perform)
    end

    after do
      Timecop.return
    end

    before { SlotCreationJob.new.perform }

    it 'performs Slot factory' do
      expect(SlotFactory).to have_received(:perform).once
    end
  end
end
