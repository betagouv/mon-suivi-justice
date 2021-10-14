require 'rails_helper'

RSpec.describe Agenda, type: :model do
  it { should validate_presence_of(:name) }

  it { should belong_to(:place) }
  it { should have_many(:slots) }
  it { should have_many(:slot_types).dependent(:destroy) }

  describe '.in_organization' do
    before do
      @organization = create :organization
      place_in = create :place, organization: @organization
      @agenda_in = create :agenda, place: place_in
      create :agenda
    end

    it 'returns correct relation' do
      expect(Agenda.in_organization(@organization)).to eq [@agenda_in]
    end
  end
end
