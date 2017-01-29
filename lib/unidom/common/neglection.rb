##
# Neglection 根据配置信息忽略指定的类或者命名空间。

class Unidom::Common::Neglection

  ##
  # 判断指定的类名是否被忽略。如:
  # Unidom::Common::Neglection.namespace_neglected? 'Namespace::ClassName'
  # 在应用的 config/initializers/unidom.rb 文件中配置如下代码，即可忽略 Namespace::ClassName 这个类。
  # Unidom::Common.configure do |options|
  # # The migrations inside the following namespaces will be ignored. The models inside the following namespaces won't be defined.
  # options[:neglected_namespaces] = %w{
  #   Namespace::ClassName
  # }

  def self.namespace_neglected?(class_name)
    neglected_namespaces = Unidom::Common.options[:neglected_namespaces]
    neglected_namespaces.present? ? neglected_namespaces.include?(class_name.to_s.deconstantize) : false
  end

end
