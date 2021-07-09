require 'rails_helper'

RSpec.describe Agenda, type: :model do
  it { should validate_presence_of(:name) }

  it { should belong_to(:place) }
  it { should have_many(:slots) }
end
