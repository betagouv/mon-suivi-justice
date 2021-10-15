require 'rails_helper'
require 'models/shared_normalized_phone'

RSpec.describe Convict, type: :model do
  it { should have_many(:appointments) }
  it { should have_many(:areas_convicts_mappings).dependent(:destroy) }
  it { should have_many(:departments).through(:areas_convicts_mappings) }
  it { should have_many(:jurisdictions).through(:areas_convicts_mappings) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:title) }

  it { should define_enum_for(:title).with_values(%i[male female]) }

  it_behaves_like 'normalized_phone'

  describe 'Validations' do
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
    it 'accepts a 06 mobile phone' do
      expect(build(:convict, phone: '0612458745')).to be_valid
    end
    it 'accepts a 07 mobile phone' do
      expect(build(:convict, phone: '0781007498')).to be_valid
    end
    it 'denies a non-mobile phone' do
      expect(build(:convict, phone: '0561083731')).not_to be_valid
    end
  end
end
