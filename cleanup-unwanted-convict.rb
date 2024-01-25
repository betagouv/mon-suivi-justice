require 'csv'

input_file = 'metz_input.csv' 
output_file = 'metz_outpu.csv' 

csv_data = CSV.read(input_file, headers: true, col_sep: ';', external_encoding: 'iso-8859-1', internal_encoding: 'utf-8')

filtered_data = csv_data.reject do |row|
  row['Affectation SPIP'].nil? || row['Affectation SPIP'].strip.empty? ||
  ['EMPRISONNEMENT', 'AMÉNAGEMENT DE PEINE', 'Placement en détention provisoire'].include?(row['Mesure/Intervention'].split(' (')[0]) ||
  row['Date de naissance'].nil? || row['Date de naissance'].strip.empty?
end

CSV.open(output_file, 'w', col_sep: ';', write_headers: true, headers: csv_data.headers, encoding: 'iso-8859-1') do |csv|
  filtered_data.each { |row| csv << row }
end
