require 'rails_helper'

RSpec.describe DataCollector do
  describe 'perform' do
    it 'collects data' do
      convict1 = create :convict
      create :convict
      3.times { create :user }

      slot1 = create :slot, date: Date.current.tomorrow
      slot2 = create :slot, date: Date.current.yesterday

      create :appointment, state: 'booked', convict: convict1, slot: slot1
      create :appointment, state: 'booked', convict: convict1, slot: slot2

      create :appointment, state: 'fulfiled', convict: convict1
      create :appointment, state: 'no_show', convict: convict1
      create :appointment, state: 'excused', convict: convict1
      create :appointment, state: 'canceled', convict: convict1

      result = DataCollector.perform

      expect(result[:convicts]).to eq(2)
      expect(result[:users]).to eq(3)

      expect(result[:recorded]).to eq(6)
      expect(result[:fulfiled]).to eq(1)
      expect(result[:no_show]).to eq(1)
      expect(result[:excused]).to eq(1)
      expect(result[:canceled]).to eq(1)

      expect(result[:future_booked]).to eq(1)
      expect(result[:passed_booked]).to eq(1)
      expect(result[:passed_no_canceled]).to eq(4)
    end
  end
end
