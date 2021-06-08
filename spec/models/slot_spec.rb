require 'rails_helper'

RSpec.describe Slot, type: :model do
  it { should belong_to(:place) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:starting_time) }
end
