module Abyme
  module Model
    def self.permit_attributes(class_name, association, attributes, permit, association_class_name = nil)
      return if ENV['APP']&.match?(/^mon-suivi-justice-staging-pr\d+/) || ENV['APP']&.match?(/^msj-agents-pentest/)
      
      @permitted_attributes[class_name]["#{association}_attributes".to_sym] = AttributesBuilder.new(class_name, association, attributes, permit, association_class_name)
      .build_attributes
    end
  end
end