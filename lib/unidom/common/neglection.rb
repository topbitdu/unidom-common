class Unidom::Common::Neglection

  def self.namespace_neglected?(class_name)
    neglected_namespaces = Unidom::Common.options[:neglected_namespaces]
    neglected_namespaces.present? ? neglected_namespaces.include?(class_name.to_s.deconstantize) : false
  end

end
