RSpec.describe ConvictsController, type: :controller do
  describe '#divestment_button_checks' do
    let(:convict) { create(:convict) }

    context 'when divestment creation is successful' do
      it 'creates a divestment and associated organization divestments' do
        # Set up any necessary objects or stubs
        # Invoke the method
        # Expect that Divestment and OrganizationDivestment count changes
      end
    end

    context 'when divestment creation fails' do
      it 'logs an error' do
        # Set up the scenario for failure
        # Invoke the method
        # Expect that an error is logged
      end
    end
  end
end
