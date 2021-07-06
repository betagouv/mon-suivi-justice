# frozen_string_literal: true

if Rails.env.development?
  RailsERD.load_tasks

  # TMP Fix for Rails 6.
  Rake::Task['erd:load_models'].clear
  Rake::Task['erd:generate'].clear

  namespace :erd do
    task :load_models do
      Rake::Task[:environment].invoke
      Zeitwerk::Loader.eager_load_all
    end

    task generate: %i[check_dependencies options load_models] do
      require 'rails_erd/diagram/graphviz'
      file = RailsERD::Diagram::Graphviz.create

      system "dot -Tpng #{file} > docs/erd.png"
      File.delete('erd.dot')

      say 'Entity-Relationship Diagram saved to docs/erd.png.'
    end
  end
end
