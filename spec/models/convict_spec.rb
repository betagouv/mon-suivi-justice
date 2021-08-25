require 'rails_helper'

RSpec.describe Convict, type: :model do
  it { should have_many(:appointments) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:title) }
  it { should define_enum_for(:title).with_values(%i[male female]) }

  describe 'Validations' do
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
    it 'accepts a blank phone with no_phone option' do
      expect(build(:convict, phone: nil, no_phone: true)).to be_valid
    end
    it 'accepts a blank phone with refused_phone option' do
      expect(build(:convict, phone: nil, refused_phone: true)).to be_valid
    end
  end
end
