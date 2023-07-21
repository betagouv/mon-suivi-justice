require 'rails_helper'
require 'date'
require 'holidays'

describe ApplicationHelper do
  describe '#next_valid_day' do
    context 'when no day parameter is given' do
      it 'returns the next valid day, skipping weekends and French holidays' do
        allow(Date).to receive(:today).and_return(Date.new(2023, 7, 21)) # Friday

        allow(Holidays).to receive(:on).with(Date.new(2023, 7, 24), :fr).and_return(true) # Monday
        allow(Holidays).to receive(:on).with(Date.new(2023, 7, 25), :fr).and_return(false) # Tuesday

        valid_day = next_valid_day

        expect(valid_day).to eq(Date.new(2023, 7, 25))
      end
    end

    context 'when a specific day parameter is given' do
      it 'returns the next valid day, skipping French holidays' do
        allow(Holidays).to receive(:on).with(Date.new(2023, 7, 24), :fr).and_return(true)
        allow(Holidays).to receive(:on).with(Date.new(2023, 7, 31), :fr).and_return(false)

        valid_day = next_valid_day(date: Date.new(2023, 7, 21), day: :monday)

        expect(valid_day).to eq(Date.new(2023, 7, 31))
      end

      it 'returns nil if day paramater falls on a weekend' do
        allow(Date).to receive(:today).and_return(Date.new(2023, 7, 21))
        allow(Holidays).to receive(:on).with(Date.new(2023, 7, 23), :fr).and_return(false)

        valid_day = next_valid_day(date: Date.new(2023, 7, 21), day: :sunday)

        expect(valid_day).to be_nil
      end
    end
  end
end
