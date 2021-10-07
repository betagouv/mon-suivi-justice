require 'rails_helper'

RSpec.describe Department, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:number) }
  it { expect(build(:department)).to validate_uniqueness_of(:name) }
  it { expect(build(:department)).to validate_uniqueness_of(:number) }
  it { should validate_inclusion_of(:number).in_array(Department::SUPPORTED.map(&:number)) }
  it { should validate_inclusion_of(:name).in_array(Department::SUPPORTED.map(&:name)) }

  describe '.seed_all_departments' do
    it 'creates 101 departement' do
      expect{Department.seed_all_departments}.to change(Department, :count).from(0).to(101)
    end
  end
end
