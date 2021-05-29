require 'rails_helper'

RSpec.describe Convict, type: :model do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:phone) }

  it { should allow_value('0687549865').for(:phone) }
  it { should_not allow_value('06845').for(:phone) }
end
