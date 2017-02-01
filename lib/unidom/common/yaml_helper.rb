##
# YAML Helper 是用于加载知识层枚举的配置文件的辅助模块。

module Unidom::Common::YamlHelper

  ##
  # 从应用或者引擎的跟路径 root 加载 config/enum.yml 中的内容到 config 中。
  def self.load_enum(config: nil, root: nil)

    enum_yaml_path = root.join 'config', 'enum.yml'
    raise ArgumentError.new "The file #{enum_yaml_path} does not exist." unless enum_yaml_path.exist?

    unless config.respond_to? :enum
      config.class_eval do
        attr_accessor :enum
      end
    end
    config.enum = {} if config.enum.nil?

    enum_definitions = YAML.load File.read(enum_yaml_path)
    config.enum.merge! enum_definitions['enum'] if enum_definitions.present?&&enum_definitions['enum'].present?

  end

end
