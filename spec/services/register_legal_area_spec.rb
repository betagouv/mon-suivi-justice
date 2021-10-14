require 'rails_helper'

RSpec.describe RegisterLegalAreas do
  describe '.for_convict' do
    it 'creates relevants convicts mappings with one organization' do
      dpt_09 = create :department, name: 'Ariège', number: '09'
      juri_09 = create :juridiction, name: 'Tribunal de foix'
      convict = create :convict
      organization = create :organization
      create :areas_organizations_mapping, organization: organization, area: dpt_09
      create :areas_organizations_mapping, organization: organization, area: juri_09
      expect do
        RegisterLegalAreas.for_convict(convict, from: organization)
      end.to change(AreasConvictsMapping, :count).from(0).to(2)
      expect(convict.reload.departments).to include dpt_09
      expect(convict.reload.juridictions).to include juri_09
    end
    it 'creates relevants convicts mappings with many organizations' do
      dpt_09 = create :department, name: 'Ariège', number: '09'
      juri_09 = create :juridiction, name: 'Tribunal de foix'
      dpt_31 = create :department, name: 'Haute-Garonne', number: '31'
      juri_31 = create :juridiction, name: 'Tribunal de toulouse'
      convict = create :convict
      organization_09 = create :organization
      organization_31 = create :organization
      create :areas_organizations_mapping, organization: organization_09, area: dpt_09
      create :areas_organizations_mapping, organization: organization_09, area: juri_09
      create :areas_organizations_mapping, organization: organization_31, area: dpt_31
      expect do
        RegisterLegalAreas.for_convict(convict, from: Organization.all)
      end.to change(AreasConvictsMapping, :count).from(0).to(3)
      expect(convict.reload.departments).to include dpt_09
      expect(convict.reload.departments).to include dpt_31
      expect(convict.reload.juridictions).to include juri_09
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
