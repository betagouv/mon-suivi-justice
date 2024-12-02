require 'rails_helper'
require 'models/shared_normalized_phone'

RSpec.describe Place, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:adress) }
  it { should validate_presence_of(:main_contact_method) }
  it { should validate_presence_of(:preparation_link) }

  it { should have_many(:agendas) }
  it { should have_many(:appointment_types).through(:place_appointment_types) }
  it { should belong_to(:organization) }

  it_behaves_like 'normalized_phone'

  describe 'Validations' do
    it 'requires a phone if it is the main_contact_method' do
      expect(build(:place, phone: nil, main_contact_method: 0)).not_to be_valid
    end
    it 'denies a blank phone' do
      expect(build(:place, phone: '')).not_to be_valid
    end
    it 'requires a phone if it is the main_contact_method' do
      expect(build(:place, contact_email: nil, main_contact_method: 1)).not_to be_valid
    end
    it 'denies a wrong email' do
      expect(build(:place, contact_email: 'youpi')).not_to be_valid
    end

    it 'denies without appointment_types' do
      expect(build(:place, appointment_types: [])).not_to be_valid
    end

    it 'is valid with the factory\'s attributes' do
      expect(build(:place)).to be_valid
    end
  end

  describe 'contact_detail' do
    let(:phonable_place) { build(:place, phone: '0606060606', main_contact_method: 0) }
    let(:emailable_place) { build(:place, contact_email: 'test@test.com', main_contact_method: 1) }

    it 'returns the correct contact_detail' do
      expect(phonable_place.contact_detail).to eq('0606060606')
      expect(emailable_place.contact_detail).to eq('test@test.com')
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
