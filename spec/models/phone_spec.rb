require 'rails_helper'

RSpec.describe Phone do
  it 'displays phone numbers properly' do
    expect(described_class.display('0687549865')).to eq '06 87 54 98 65'
  end

  describe 'format' do
    it 'adds prefix when number starts with 0' do
      expect(Phone.format('0687549865')).to eq '+33687549865'
    end

    it 'returns nil if it doesnt start with 0' do
      expect(Phone.format('7687549865')).to be nil
    end
  end
end
