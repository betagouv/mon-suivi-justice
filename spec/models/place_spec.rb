require 'rails_helper'
require 'models/shared_normalized_phone'

RSpec.describe Place, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:adress) }
  it { should validate_presence_of(:main_contact_method) }

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

  describe '.in_department' do
    it 'returns places scoped by department' do
      department1 = create :department, number: '01', name: 'Ain'

      organization1 = create :organization
      create :areas_organizations_mapping, organization: organization1, area: department1
      place1 = create :place, organization: organization1

      organization2 = create :organization
      create :areas_organizations_mapping, organization: organization2, area: department1
      place2 = create :place, organization: organization2

      department2 = create :department, number: '02', name: 'Aisne'

      organization3 = create :organization
      create :areas_organizations_mapping, organization: organization3, area: department2
      create :place, organization: organization3

      expect(Place.in_department(department1)).to eq [place1, place2]
    end
  end
end
