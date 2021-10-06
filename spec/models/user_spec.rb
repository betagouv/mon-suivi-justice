require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:role) }

  it { should define_enum_for(:role).with_values(%i[admin bex cpip sap]) }

  it { should belong_to(:organization) }
end
