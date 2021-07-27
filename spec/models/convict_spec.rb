require 'rails_helper'

RSpec.describe Convict, type: :model do
  it { should have_many(:appointments) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:title) }

  it { should define_enum_for(:title).with_values(%i[male female]) }

  it { should allow_value('0687549865').for(:phone) }
  # it { should allow_value('06 87 54 98 65').for(:phone) }
  it { should_not allow_value('06845').for(:phone) }

  context 'validations' do
    describe 'phone_situation' do
      it 'fails if phone is blank and refused_phone is false and no_phone is false' do
        convict = build(:convict, phone: '', refused_phone: false, no_phone: false)
        convict.valid?

        expect(convict.errors).to include(:phone)
      end

      it 'passes if phone is blank and refused_phone is false and no_phone is true' do
        convict = build(:convict, phone: '', refused_phone: false, no_phone: true)

        expect(convict).to be_valid
      end

      it 'passes if phone is blank and refused_phone is true and no_phone is false' do
        convict = build(:convict, phone: '', refused_phone: true, no_phone: false)

        expect(convict).to be_valid
      end
    end
  end
end
