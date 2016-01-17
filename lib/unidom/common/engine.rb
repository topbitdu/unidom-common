module Unidom
  module Common

    class Engine < ::Rails::Engine

      config.autoload_paths += %W(
        #{config.root}/lib
        #{config.root}/app/models/unidom/common/concerns
      )

      config.eager_load_paths += %W(
        #{config.root}/lib
        #{config.root}/app/models/unidom/common/concerns
      )

      isolate_namespace ::Unidom::Common

      initializer :append_migrations do |app|
        #app.config.paths['db/migrate'] += config.paths['db/migrate'].expanded unless app.root.to_s==root.to_s
        config.paths['db/migrate'].expanded.each { |expanded_path| app.config.paths['db/migrate'] << expanded_path } unless app.root.to_s.match root.to_s
      end

    end

  end
end
