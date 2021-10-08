require 'rails_helper'
require 'models/shared_normalized_phone'

RSpec.describe Place, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:adress) }
  it { should validate_presence_of(:phone) }

  it { should have_many(:agendas) }
  it { should have_many(:appointment_types).through(:place_appointment_types) }
  it { should belong_to(:organization) }

  it_behaves_like 'normalized_phone'

  describe 'Validations' do
    it 'requires a phone' do
      expect(build(:convict, phone: nil)).not_to be_valid
    end
    it 'denies a blank phone' do
      expect(build(:convict, phone: '')).not_to be_valid
    end
  end

  describe '.in_organization' do
    before do
      @organization = create :organization
      @place_in = create :place, organization: @organization
      create :place
    end

    it 'returns correct relation' do
      expect(Place.in_organization(@organization)).to eq [@place_in]
    end
  end
end
