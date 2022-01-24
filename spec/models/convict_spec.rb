# == Schema Information
#
# Table name: convicts
#
#  id                :bigint           not null, primary key
#  appi_uuid         :string
#  discarded_at      :datetime
#  first_name        :string
#  last_name         :string
#  no_phone          :boolean
#  phone             :string
#  prosecutor_number :string
#  refused_phone     :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_convicts_on_discarded_at  (discarded_at)
#
require 'rails_helper'
require 'models/shared_normalized_phone'

RSpec.describe Convict, type: :model do
  it { should have_many(:appointments) }
  it { should have_many(:areas_convicts_mappings).dependent(:destroy) }
  it { should have_many(:departments).through(:areas_convicts_mappings) }
  it { should have_many(:jurisdictions).through(:areas_convicts_mappings) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_uniqueness_of(:appi_uuid) }

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
    it 'accepts multiples user with no-data for appi uuid' do
      create(:convict, appi_uuid: nil)
      expect(build(:convict, appi_uuid: nil)).to be_valid
    end
  end

  describe 'under_hand_of' do
    let!(:dpt01) { create :department, number: '01', name: 'Ain' }
    let!(:dpt02) { create :department, number: '02', name: 'Aisne' }
    let!(:dpt03) { create :department, number: '03', name: 'Allier' }
    let!(:juri01) { create :jurisdiction, name: 'jurisdiction_1' }
    let!(:juri02) { create :jurisdiction, name: 'jurisdiction_2' }
    let!(:juri03) { create :jurisdiction, name: 'jurisdiction_3' }
    let!(:convict1) { create :convict }
    let!(:convict2) { create :convict }
    let!(:orga) { create :organization }

    context 'with jurisdiction & department' do
      before do
        create :areas_organizations_mapping, organization: orga, area: dpt01
        create :areas_organizations_mapping, organization: orga, area: juri01
        create :areas_convicts_mapping, convict: convict1, area: dpt01
        create :areas_convicts_mapping, convict: convict1, area: juri01
        create :areas_convicts_mapping, convict: convict2, area: juri01
        create :areas_convicts_mapping, convict: convict1, area: dpt02
        create :areas_convicts_mapping, convict: convict2, area: juri02
        create :areas_convicts_mapping, area: dpt03
        create :areas_convicts_mapping, area: juri03
      end

      it 'return 2 convicts' do
        expect(Convict.under_hand_of(orga).count).to eq 2
      end
      it 'includes convict from the department' do
        expect(Convict.under_hand_of(orga)).to include convict1
      end
      it 'includes second from the jurisdiction' do
        expect(Convict.under_hand_of(orga)).to include convict2
      end
    end

    context 'with only jurisdiction' do
      before do
        create :areas_organizations_mapping, organization: orga, area: juri01
        create :areas_convicts_mapping, convict: convict1, area: dpt01
        create :areas_convicts_mapping, convict: convict1, area: juri01
        create :areas_convicts_mapping, convict: convict2, area: dpt01
        create :areas_convicts_mapping, convict: convict1, area: dpt02
        create :areas_convicts_mapping, convict: convict2, area: juri01
        create :areas_convicts_mapping, area: dpt03
        create :areas_convicts_mapping, area: juri03
      end

      it 'return 2 convicts' do
        expect(Convict.under_hand_of(orga).count).to eq 2
      end
      it 'includes convict from the department' do
        expect(Convict.under_hand_of(orga)).to include convict1
      end
      it 'includes second from the jurisdiction' do
        expect(Convict.under_hand_of(orga)).to include convict2
      end
    end

    context 'with only department' do
      before do
        create :areas_organizations_mapping, organization: orga, area: dpt01
        create :areas_convicts_mapping, convict: convict1, area: dpt01
        create :areas_convicts_mapping, convict: convict1, area: juri01
        create :areas_convicts_mapping, convict: convict2, area: dpt01
        create :areas_convicts_mapping, convict: convict1, area: dpt02
        create :areas_convicts_mapping, convict: convict2, area: juri01
        create :areas_convicts_mapping, area: dpt03
        create :areas_convicts_mapping, area: juri03
      end

      it 'return 2 convicts' do
        expect(Convict.under_hand_of(orga).count).to eq 2
      end
      it 'includes convict from the department' do
        expect(Convict.under_hand_of(orga)).to include convict1
      end
      it 'includes second from the jurisdiction' do
        expect(Convict.under_hand_of(orga)).to include convict2
      end
    end

    context 'with an organization without any jurisdiction or department' do
      before do
        create :areas_convicts_mapping, convict: convict1, area: dpt01
        create :areas_convicts_mapping, convict: convict1, area: juri01
        create :areas_convicts_mapping, convict: convict2, area: dpt01
        create :areas_convicts_mapping, convict: convict1, area: dpt02
        create :areas_convicts_mapping, convict: convict2, area: juri02
        create :areas_convicts_mapping, area: dpt03
        create :areas_convicts_mapping, area: juri03
      end

      it 'return 0 convicts' do
        expect(Convict.under_hand_of(orga).count).to eq 0
      end
    end

    context 'with no convict in jurisdiction & department' do
      before do
        create :areas_organizations_mapping, organization: orga, area: dpt01
        create :areas_organizations_mapping, organization: orga, area: juri01
        create :areas_convicts_mapping, convict: convict1, area: dpt02
        create :areas_convicts_mapping, convict: convict1, area: juri03
        create :areas_convicts_mapping, convict: convict2, area: juri02
        create :areas_convicts_mapping, convict: convict2, area: dpt03
        create :areas_convicts_mapping, area: dpt03
        create :areas_convicts_mapping, area: juri03
      end

      it 'return 0 convicts' do
        expect(Convict.under_hand_of(orga).count).to eq 0
      end
    end
  end

  describe '.in_department' do
    it 'returns convicts scoped by department' do
      department1 = create :department, number: '01', name: 'Ain'

      convict1 = create :convict
      create :areas_convicts_mapping, convict: convict1, area: department1

      convict2 = create :convict
      create :areas_convicts_mapping, convict: convict2, area: department1

      department2 = create :department, number: '02', name: 'Aisne'

      convict3 = create :convict
      create :areas_convicts_mapping, convict: convict3, area: department2

      expect(Convict.in_department(department1)).to eq [convict1, convict2]
    end
  end
end
