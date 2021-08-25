require 'rails_helper'

RSpec.describe Place, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:adress) }
  it { should validate_presence_of(:place_type) }
  it { should validate_presence_of(:phone) }
  it { should have_many(:agendas) }
  it { should define_enum_for(:place_type).with_values(%i[spip sap]) }

  describe 'Phone validations' do
    it 'denies a non-digit number' do
      expect(build(:convict, phone: 'my phone number')).not_to be_valid
    end
    it 'denies a non-sense number' do
      expect(build(:convict, phone: 'zero six 56ù% abc')).not_to be_valid
    end
    it 'denies a invalid number' do
      expect(build(:convict, phone: '958748751245876321448')).not_to be_valid
    end
    it 'denies a too short number' do
      expect(build(:convict, phone: '1234')).not_to be_valid
    end
    it 'accepts a valid number with country prefix' do
      expect(build(:convict, phone: '+33561083731')).to be_valid
    end
    it 'accepts a valid number without country prefix' do
      expect(build(:convict, phone: '0561083731')).to be_valid
    end
    it 'accepts a valid number with space' do
      expect(build(:convict, phone: '05 61 08 37 31')).to be_valid
    end
    it 'accepts a valid number with dot' do
      expect(build(:convict, phone: '05.61.08.37.31')).to be_valid
    end
    it 'accepts a valid number with dash' do
      expect(build(:convict, phone: '05-61-08-37-31')).to be_valid
    end
    it 'normalizes a valid number with country prefix' do
      convict = create(:convict, phone: '+33561083731')
      expect(convict.reload.phone).to eq '+33561083731'
    end
    it 'normalizes a valid number without country prefix' do
      convict = create(:convict, phone: '0561083731')
      expect(convict.reload.phone).to eq '+33561083731'
    end
    it 'normalizes a valid number with space' do
      convict = create(:convict, phone: '05 61 08 37 31')
      expect(convict.reload.phone).to eq '+33561083731'
    end
    it 'normalizes a valid number with dot' do
      convict = create(:convict, phone: '05.61.08.37.31')
      expect(convict.reload.phone).to eq '+33561083731'
    end
    it 'normalizes a valid number with dash' do
      convict = create(:convict, phone: '05-61-08-37-31')
      expect(convict.reload.phone).to eq '+33561083731'
    end
    it 'requires a phone' do
      expect(build(:convict, phone: nil)).not_to be_valid
    end
    it 'denies a blank phone' do
      expect(build(:convict, phone: '')).not_to be_valid
    end
  end

  describe '#display_phone' do

    it 'returns correct phone value with a french number' do
      expect(create(:convict, phone: '+33561083731').display_phone).to eq '05 61 08 37 31'
    end
    it 'returns correct phone value with a UK number' do
      expect(create(:convict, phone: '+443031237300').display_phone).to eq '0303 123 7300'
    end
  end
end
