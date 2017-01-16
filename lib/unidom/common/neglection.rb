class Unidom::Common::Neglection

  def self.namespace_neglected?(class_name)
    Unidom::Common.options[:neglected_namespaces].include? class_name.to_s.deconstantize
  end

end
