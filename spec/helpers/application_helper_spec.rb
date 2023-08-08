require 'rails_helper'
require 'date'
require 'holidays'

describe ApplicationHelper do
  describe '#next_valid_day' do
    context 'when no day parameter is given' do
      it 'returns the next valid day, skipping weekends and French holidays' do
        allow(Time.zone).to receive(:today).and_return(Date.new(2023, 7, 21)) # Friday

        allow(Holidays).to receive(:on).with(Date.new(2023, 7, 24), :fr).and_return([{ name: 'a holiday' }]) # Monday
        allow(Holidays).to receive(:on).with(Date.new(2023, 7, 25), :fr).and_return([]) # Tuesday

        valid_day = next_valid_day

        expect(valid_day).to eq(Date.new(2023, 7, 25))
      end
    end

    context 'when a specific day parameter is given' do
      it 'returns the next valid day, skipping French holidays' do
        allow(Holidays).to receive(:on).with(Date.new(2023, 7, 24), :fr).and_return([{ name: 'a holiday' }])
        allow(Holidays).to receive(:on).with(Date.new(2023, 7, 31), :fr).and_return([])

        valid_day = next_valid_day(date: Date.new(2023, 7, 21), day: :monday)

        expect(valid_day).to eq(Date.new(2023, 7, 31))
      end

      it 'throw if day parameter falls on a weekend' do
        allow(Date).to receive(:today).and_return(Date.new(2023, 7, 21))
        allow(Holidays).to receive(:on).with(Date.new(2023, 7, 23), :fr).and_return(false)

        expect { next_valid_day(day: :saturday) }.to raise_error(ArgumentError)
        expect { next_valid_day(day: :sunday) }.to raise_error(ArgumentError)
      end
    end
  end
end
