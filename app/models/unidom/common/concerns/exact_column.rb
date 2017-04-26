##
# Exact Column 为加密数据提供摘要索引。

module Unidom::Common::Concerns::ExactColumn

  extend ActiveSupport::Concern

  included do |includer|

    cattr_accessor :exact_column_names

  end

  module ClassMethods

    ##
    # 配置精确索引列。如：
    # class SomeModel
    #   include Unidom::Common::Concerns::ExactColumn
    #   exact_column :phone_number, :identification_number
    # end
    def exact_column(*names)

      exact_column_names = exact_column_names||[]
      exact_column_names += names

      names.each do |name|
        name = name.to_s
        instance_eval do
          scope :"#{name}_is", ->(value) { where "#{name}_exact_signature" => exact_signature(self, name, value) }
          before_save do send "#{name}_exact_signature=", self.class.exact_signature(self.class, name, send(name)) end
        end
      end

    end

    ##
    # 计算精确索引列的值。此方法被 exact_column 方法调用。
    def exact_signature(klass, name, value, secret_key_base: Rails.application.secrets[:secret_key_base])
      text = "#{secret_key_base}/#{klass.table_name}##{name}=#{value}"
      #text = "#{Rails.application.secrets[:secret_key_base]}@#{Rails.root}/#{klass.table_name}##{name}=#{value}"
      "#{Digest::MD5.digest(text)}#{Digest::SHA512.digest(text)}"
    end

  end

end
