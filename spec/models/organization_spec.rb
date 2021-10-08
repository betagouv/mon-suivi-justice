require 'rails_helper'

RSpec.describe Organization, type: :model do
  it { should validate_presence_of(:name) }
  it { should have_many(:users).dependent(:destroy) }
  it { should have_many(:places).dependent(:destroy) }
  it { should have_many(:areas_organizations_mappings).dependent(:destroy) }
  it { should have_many(:departments).through(:areas_organizations_mappings) }
end
