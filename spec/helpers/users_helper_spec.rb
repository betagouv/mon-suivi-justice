require 'rails_helper'

describe UsersHelper do
  describe '#places_options_for_select' do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization:) }

    before do
      @place1 = create(:place, organization:, name: 'Place1')
      @place2 = create(:place, organization:, name: 'Place2', discarded_at: Time.now)
    end

    it 'returns formatted options for select' do
      options = helper.places_options_for_select(user)

      expect(options).to include(['Place1', @place1.id])
      expect(options).to include(['Place2 (Archivé)', @place2.id])
    end
  end
end
