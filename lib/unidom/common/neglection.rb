##
# Neglection 根据配置信息忽略指定的类或者命名空间。

class Unidom::Common::Neglection

  def self.namespace_neglected?(class_name)
    neglected_namespaces = Unidom::Common.options[:neglected_namespaces]
    neglected_namespaces.present? ? neglected_namespaces.include?(class_name.to_s.deconstantize) : false
  end

end
