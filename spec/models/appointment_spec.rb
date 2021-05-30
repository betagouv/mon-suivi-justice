require 'rails_helper'

RSpec.describe Appointment, type: :model do
  it { should belong_to(:convict)}
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:slot) }

  # it { should define_enum_for(:slot).with_values([:admin, :bex, :cpip])}
end
