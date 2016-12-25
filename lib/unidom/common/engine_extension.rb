module Unidom::Common::EngineExtension

  extend ActiveSupport::Concern

  #included do |includer|
  #end

  module ClassMethods

    def enable_initializer(enum_enabled: false, migration_enabled: false)

      if enum_enabled
        require 'unidom/common/yaml_helper'
        initializer :load_config_initializers do |app|
          Unidom::Common::YamlHelper.load_enum config: app.config, root: config.root
        end
      end

      if migration_enabled
        initializer :append_migrations do |app|
          config.paths['db/migrate'].expanded.each { |expanded_path| app.config.paths['db/migrate'] << expanded_path } unless app.root.to_s.match root.to_s
        end
      end

    end

  end

end
