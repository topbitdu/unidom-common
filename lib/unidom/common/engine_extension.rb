##
# Engine Extension 是为 Rails 引擎提供的扩展关注点。
# .enable_initializer 方法简化了知识层枚举和数据库迁移脚本的加载。

module Unidom::Common::EngineExtension

  extend ActiveSupport::Concern

  #included do |includer|
  #end

  module ClassMethods

    ##
    # 设置初始化器的开关。如:
    # Unidom::Common::EngineExtension.enable_initializer enum_enabled: true, migration_enabled: false
    # enum_enabled 表明是否加载枚举型。
    # migration_enabled 表明是否运行领域模型数据库迁移脚本，同时也表明加载对应的领域模型。
    def enable_initializer(enum_enabled: false, migration_enabled: false)

      if enum_enabled
        require 'unidom/common/yaml_helper'
        initializer :load_config_initializers do |app|
          Unidom::Common::YamlHelper.load_enum config: app.config, root: config.root
        end
      end

      if migration_enabled
        initializer :append_migrations do |app|
          config.paths['db/migrate'].expanded.each { |expanded_path| app.config.paths['db/migrate'] << expanded_path } unless Unidom::Common::Neglection.namespace_neglected?(self.class.name)||app.root.to_s.match(root.to_s)
        end
      end

    end

  end

end
