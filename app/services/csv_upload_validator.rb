class CsvUploadValidator
  MAX_SIZE = 10.megabytes

  class ValidationError < StandardError
  end

  def self.call!(uploaded_file)
    extension = File.extname(uploaded_file.original_filename).downcase
    raise ValidationError, 'Seul le format csv est supporté' unless extension == '.csv'
    raise ValidationError, 'Fichier trop volumineux' if uploaded_file.size > MAX_SIZE

    sample = uploaded_file.tempfile.read(2048)
    uploaded_file.tempfile.rewind
    raise ValidationError, 'Le contenu du fichier ne correspond pas à un CSV valide' if binary?(sample)
  end

  def self.binary?(sample)
    return false if sample.blank?

    sample.include?("\x00") || (!sample.valid_encoding? && !sample.dup.force_encoding('ISO-8859-1').valid_encoding?)
  end
end
