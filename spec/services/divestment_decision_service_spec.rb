# spec/services/divestment_creator_spec.rb
require 'rails_helper'

RSpec.describe DivestmentCreatorService do
  let(:user) { create(:user, :in_organization, role: 'cpip') }
  let(:convict) { create(:convict) }

  subject(:service) { DivestmentCreatorService.new(convict, user) }

  describe '#call' do
  end
end
