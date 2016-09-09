module Unidom::Common::Concerns::Sha256Digester

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
      message.present? ? Digest::SHA256.digest("#{message}_#{Rails.application.secrets[:secret_key_base]}_#{pepper}") : nil
    end

    def hex_digest(message, pepper: nil)
      message.present? ? Unidom::Common::Numeration.hex(digest(message, pepper: pepper)) : nil
    end

  end

end
