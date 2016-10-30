module Unidom::Common::Concerns::Aes256Cryptor

  extend ActiveSupport::Concern

  included do |includer|

    def encrypt(message, key: nil)
      self.class.encrypt message, key: key
    end

    def decrypt(encoded, key: nil)
      self.class.decrypt encoded, key: key
    end

    def aes_256_padding
      self.class.aes_256_padding
    end

    def hex_encrypt(message, key: nil)
      self.class.hex_encrypt message, key: key
    end

    def hex_decrypt(encoded, key: nil)
      self.class.hex_decrypt encoded, key: key
    end

  end

  module ClassMethods

    def encryption_algorithm
      'AES-256-CBC'
    end

    def encrypt(message, key: nil)

      raise ArgumentError.new('The message argument is required.') if message.blank?
      raise ArgumentError.new('The key argument is required.')     if key.blank?

      cipher = OpenSSL::Cipher::AES.new(256, 'CBC')
      cipher.encrypt
      cipher.padding = aes_256_padding
      cipher.key     = key

      cipher.update(message)+cipher.final

    end

    def decrypt(encoded, key: nil)

      raise ArgumentError.new('The encoded argument is required.') if encoded.blank?
      raise ArgumentError.new('The key argument is required.')     if key.blank?

      cipher = OpenSSL::Cipher::AES.new(256, 'CBC')
      cipher.decrypt
      cipher.padding = aes_256_padding
      cipher.key     = key

      cipher.update(encoded)+cipher.final

    end

    def aes_256_padding
      respond_to?(:cryption_padding) ? cryption_padding : 9
    end

    def hex_encrypt(message, key: nil)
      Unidom::Common::Numeration.hex encrypt(message, key: key)
    end

    def hex_decrypt(encoded, key: nil)
      Unidom::Common::Numeration.hex decrypt(Unidom::Common::Numeration.rev_hex(encoded), key: key)
    end

  end

end
