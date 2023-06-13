module Abyme
  module Model
    def self.permit_attributes(class_name, association, attributes, permit, association_class_name = nil)
      return if ENV['APP']&.match?(/^mon-suivi-justice-staging-pr\d+/)
      p '== the APP =='
      p ENV.fetch('APP', nil)
      p '============='
      @permitted_attributes[class_name]["#{association}_attributes".to_sym] = AttributesBuilder.new(class_name, association, attributes, permit, association_class_name)
      .build_attributes
    end
  end
end