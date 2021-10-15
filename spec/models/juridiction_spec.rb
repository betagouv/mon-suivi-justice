require 'rails_helper'

RSpec.describe Jurisdiction, type: :model do
  it { should validate_presence_of(:name) }
  it { expect(build(:jurisdiction)).to validate_uniqueness_of(:name) }

  it { should have_many(:areas_organizations_mappings).dependent(:destroy) }
  it { should have_many(:organizations).through(:areas_organizations_mappings) }
end
