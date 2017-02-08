##
# MD-5 Digester 基于 MD-5 算法的摘要逻辑关注点。

module Unidom::Common::Concerns::Md5Digester

  extend ActiveSupport::Concern

  included do |includer|

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
