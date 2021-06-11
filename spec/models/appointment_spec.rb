require 'rails_helper'

RSpec.describe Appointment, type: :model do
  it { should belong_to(:convict) }
  it { should belong_to(:slot) }
end
