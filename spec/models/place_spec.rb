require 'rails_helper'

RSpec.describe Place, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:adress) }

  it { should allow_value('0687549865').for(:phone) }
  # it { should allow_value('06 87 54 98 65').for(:phone) }
  it { should_not allow_value('06845').for(:phone) }
end
