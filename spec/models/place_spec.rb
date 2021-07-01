require 'rails_helper'

RSpec.describe Place, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:adress) }
  it { should validate_presence_of(:place_type) }

  it { should allow_value('0687549865').for(:phone) }
  # it { should allow_value('06 87 54 98 65').for(:phone) }
  it { should_not allow_value('06845').for(:phone) }

  it { should define_enum_for(:place_type).with_values(%i[spip sap]) }
end
