module Unidom::Common::Concerns::ExactColumn

  extend ActiveSupport::Concern

  included do |includer|
  end

  module ClassMethods

    def exact_column(*names)
      names.each do |name|
        name = name.to_s
        instance_eval do
          scope :"#{name}_is", ->(value) { where "#{name}_exact_signature" => exact_signature(self, name, value) }
          before_save do
            send "#{name}_exact_signature=", self.class.exact_signature(self.class, name, send(name))
          end
        end
      end
    end

    def exact_signature(klass, name, value)
      text = "#{Rails.application.secrets[:secret_key_base]}@#{Rails.root}/#{klass.table_name}##{name}=#{value}"
      "#{Digest::MD5.digest(text)}#{Digest::SHA512.digest(text)}"
    end

  end

end