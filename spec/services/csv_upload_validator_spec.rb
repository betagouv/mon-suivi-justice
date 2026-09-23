require 'rails_helper'

RSpec.describe CsvUploadValidator do
  def uploaded_file(fixture_name)
    Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/#{fixture_name}"), 'text/csv')
  end

  it 'accepts a valid csv file' do
    expect { described_class.call!(uploaded_file('valid_convicts.csv')) }.not_to raise_error
  end

  it 'rejects a file that is not a .csv' do
    expect { described_class.call!(uploaded_file('valid_convicts.txt')) }
      .to raise_error(CsvUploadValidator::ValidationError, 'Seul le format csv est supporté')
  end

  it 'rejects a binary file disguised with a .csv extension' do
    expect { described_class.call!(uploaded_file('binary_disguised_as.csv')) }
      .to raise_error(CsvUploadValidator::ValidationError, 'Le contenu du fichier ne correspond pas à un CSV valide')
  end

  it 'rejects a file larger than the size limit' do
    stub_const('CsvUploadValidator::MAX_SIZE', 10)

    expect { described_class.call!(uploaded_file('valid_convicts.csv')) }
      .to raise_error(CsvUploadValidator::ValidationError, 'Fichier trop volumineux')
  end
end
