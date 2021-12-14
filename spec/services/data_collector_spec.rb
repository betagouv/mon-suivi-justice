require 'rails_helper'

RSpec.describe DataCollector do
  describe 'perform' do
    it 'collects data' do
      2.times { create :convict }
      3.times { create :user }
      create :appointment, state: 'booked'
      create :appointment, state: 'fulfiled'
      create :appointment, state: 'no_show'
      create :appointment, state: 'excused'
      create :appointment, state: 'canceled'

      result = DataCollector.perform

      expect(result[:convicts]).to eq(2)
      expect(result[:users]).to eq(3)

      expect(result[:recorded]).to eq(5)
      expect(result[:fulfiled]).to eq(1)
      expect(result[:no_show]).to eq(1)
      expect(result[:excused]).to eq(1)
      expect(result[:canceled]).to eq(1)

      expect(result[:future_booked]).to eq(1)
      expect(result[:passed_booked]).to eq(1)
      expect(result[:passed_no_canceled]).to eq(1)
    end
  end
end
