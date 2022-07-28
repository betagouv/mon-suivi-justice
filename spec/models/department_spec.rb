require 'rails_helper'

RSpec.describe Department, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:number) }
  it { expect(build(:department)).to validate_uniqueness_of(:name) }
  it { expect(build(:department)).to validate_uniqueness_of(:number) }
  it { should validate_inclusion_of(:number).in_array(FRENCH_DEPARTMENTS.map(&:number)) }
  it { should validate_inclusion_of(:name).in_array(FRENCH_DEPARTMENTS.map(&:name)) }

  it { should have_many(:areas_organizations_mappings).dependent(:destroy) }
  it { should have_many(:organizations).through(:areas_organizations_mappings) }
  it { should have_many(:areas_convicts_mappings).dependent(:destroy) }
  it { should have_many(:convicts).through(:areas_convicts_mappings) }

  describe 'tribunal' do
    it 'returns the first tribunal of the department' do
      department = create(:department)
      organization = create(:organization, organization_type: 'tj')
      create :areas_organizations_mapping, organization: organization, area: department, area_type: 'Department'

      expect(department.tribunal).to eq(organization)
    end
  end
end
