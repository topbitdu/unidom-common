##
# MD-5 Digester 基于 MD-5 算法的摘要逻辑关注点。

module Unidom::Common::Concerns::Md5Digester

  extend ActiveSupport::Concern

  included do |includer|

    ##
    # 对明文 message 进行 MD-5 摘要， pepper 是用于增加混乱的内容。如：
    # class SomeModel
    #   include Unidom::Common::Concerns::Md5Digester
    #   def some_method(param_1)
    #     digest param_1
    #     # 或者
    #     digest param_1, pepper: 'my_pepper'
    #   end
    # end
    def digest(message, pepper: nil)
      self.class.digest message, pepper: pepper
    end

    def hex_digest(message, pepper: nil)
      self.class.hex_digest message, pepper: pepper
    end

  end

  module ClassMethods

    def digest(message, pepper: nil)
      message.present? ? Digest::MD5.digest("#{message}_#{Rails.application.secrets[:secret_key_base]}_#{pepper}") : nil
    end

    def hex_digest(message, pepper: nil)
      message.present? ? Unidom::Common::Numeration.hex(digest(message, pepper: pepper)) : nil
    end

  end

end
