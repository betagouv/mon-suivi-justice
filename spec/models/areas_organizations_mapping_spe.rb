require 'rails_helper'

RSpec.describe AreasOrganizationsMapping, type: :model do
  it { should validate_inclusion_of(:area_type).in_array(['Department']) }
  it { should belong_to(:organization) }
  it { should belong_to(:area) }
end
