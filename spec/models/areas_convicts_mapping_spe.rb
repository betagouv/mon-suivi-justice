require 'rails_helper'

RSpec.describe AreasConvictsMapping, type: :model do
  it { should validate_inclusion_of(:area_type).in_array(%w[Department Jurisdiction]) }
  it { should belong_to(:convict) }
  it { should belong_to(:area) }
end
