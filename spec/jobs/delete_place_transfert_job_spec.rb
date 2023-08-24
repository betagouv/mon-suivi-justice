require 'rails_helper'

RSpec.describe DeletePlaceTransfertJob, type: :job do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  let!(:place_transfert_done) do
    travel_to 2.months.ago do
      create(:place_transfert, status: :transfert_done, date: 1.day.from_now)
    end
  end
  let!(:place_transfert_pending) do
    travel_to 2.months.ago do
      create(:place_transfert, status: :transfert_pending, date: 1.day.from_now)
    end
  end
  let!(:place_transfert_recent) do
    travel_to 1.week.ago do
      create(:place_transfert, status: :transfert_done, date: 1.day.from_now)
    end
  end

  it 'deletes place transferts with status done and date older than 1 month' do
    expect do
      perform_enqueued_jobs { described_class.perform_later }
    end.to change(PlaceTransfert, :count).by(-1)

    expect(PlaceTransfert.exists?(place_transfert_done.id)).to be false
    expect(PlaceTransfert.exists?(place_transfert_pending.id)).to be true
    expect(PlaceTransfert.exists?(place_transfert_recent.id)).to be true
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
