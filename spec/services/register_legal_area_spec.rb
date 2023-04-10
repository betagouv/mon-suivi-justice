require 'rails_helper'

RSpec.describe RegisterLegalAreas do
  describe '.for_convict' do
    it 'creates relevants convicts mappings with one organization' do
      dpt09 = create :department, name: 'Ariège', number: '09'
      juri09 = create :jurisdiction, name: 'Tribunal de foix'
      convict = create :convict
      organization = create :organization
      create :areas_organizations_mapping, organization: organization, area: dpt09
      create :areas_organizations_mapping, organization: organization, area: juri09
      expect do
        RegisterLegalAreas.for_convict(convict, from: organization)
      end.to change(AreasConvictsMapping, :count).from(0).to(2)
      expect(convict.reload.departments).to include dpt09
      expect(convict.reload.jurisdictions).to include juri09
    end
    it 'creates relevants convicts mappings with many organizations' do
      dpt09 = create :department, name: 'Ariège', number: '09'
      juri09 = create :jurisdiction, name: 'Tribunal de foix'
      dpt31 = create :department, name: 'Haute-Garonne', number: '31'
      convict = create :convict
      organization09 = create :organization
      organization31 = create :organization
      create :areas_organizations_mapping, organization: organization09, area: dpt09
      create :areas_organizations_mapping, organization: organization09, area: juri09
      create :areas_organizations_mapping, organization: organization31, area: dpt31
      expect do
        RegisterLegalAreas.for_convict(convict, from: Organization.all)
      end.to change(AreasConvictsMapping, :count).from(0).to(3)
      expect(convict.reload.departments).to include dpt09
      expect(convict.reload.departments).to include dpt31
      expect(convict.reload.jurisdictions).to include juri09
    end
    it 'does not creates any convicts mappings with no organization' do
      convict = create :convict
      expect do
        RegisterLegalAreas.for_convict(convict, from: Organization.none)
      end.not_to change(AreasConvictsMapping, :count)
    end
    it 'does not creates any convicts mappings with no convict' do
      organization = create :organization
      create :areas_organizations_mapping, organization: organization
      expect { RegisterLegalAreas.for_convict(nil, from: Organization.all) }.not_to change(AreasConvictsMapping, :count)
    end
  end
end
