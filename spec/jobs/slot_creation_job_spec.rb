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
    let(:frozen_time) { Time.zone.parse '2021-05-03' }
    before do
      allow(Time).to receive(:now).and_return frozen_time
      allow(SlotFactory).to receive(:perform)
    end

    before { SlotCreationJob.new.perform }

    it 'performs Slot factory' do
      expect(SlotFactory).to have_received(:perform).once
    end
  end
end
