RSpec.shared_examples_for 'normalized_phone' do
  let(:model) { described_class }
  let(:model_factory) { model.to_s.underscore.to_sym }

  describe 'Phone validations' do
    it 'denies a non-digit number' do
      expect(build(model_factory, phone: 'my phone number')).not_to be_valid
    end
    it 'denies a non-sense number' do
      expect(build(model_factory, phone: 'zero six 56ù% abc')).not_to be_valid
    end
    it 'denies a invalid number' do
      expect(build(model_factory, phone: '958748751245876321448')).not_to be_valid
    end
    it 'denies a too short number' do
      expect(build(model_factory, phone: '1234')).not_to be_valid
    end
    it 'accepts a valid number with country prefix' do
      expect(build(model_factory, phone: '+33661083731')).to be_valid
    end
    it 'accepts a valid number without country prefix' do
      expect(build(model_factory, phone: '0661083731')).to be_valid
    end
    it 'accepts a valid number with space' do
      expect(build(model_factory, phone: '06 61 08 37 31')).to be_valid
    end
    it 'accepts a valid number with dot' do
      expect(build(model_factory, phone: '07.61.08.37.31')).to be_valid
    end
    it 'accepts a valid number with dash' do
      expect(build(model_factory, phone: '07-61-08-37-31')).to be_valid
    end
  end

  describe 'Phone normalization' do
    it 'normalizes a valid number with country prefix' do
      ressource = create(model_factory, phone: '+33661083731')
      expect(ressource.reload.phone).to eq '+33661083731'
    end
    it 'normalizes a valid number without country prefix' do
      ressource = create(model_factory, phone: '0661083731')
      expect(ressource.reload.phone).to eq '+33661083731'
    end
    it 'normalizes a valid number with space' do
      ressource = create(model_factory, phone: '07 61 08 37 31')
      expect(ressource.reload.phone).to eq '+33761083731'
    end
    it 'normalizes a valid number with dot' do
      ressource = create(model_factory, phone: '07.61.08.37.31')
      expect(ressource.reload.phone).to eq '+33761083731'
    end
    it 'normalizes a valid number with dash' do
      ressource = create(model_factory, phone: '07-61-08-37-31')
      expect(ressource.reload.phone).to eq '+33761083731'
    end
  end

  describe '#display_phone' do
    it 'returns correct phone value with a french number' do
      expect(create(model_factory, phone: '+33661083731').display_phone).to eq '06 61 08 37 31'
    end
  end
end
