##
# AES 256 Cryptor 是基于 AES-256-CBC 算法的加密和解密逻辑关注点。

module Unidom::Common::Concerns::Aes256Cryptor

  extend ActiveSupport::Concern

  included do |includer|

    ##
    # 将明文 message 用秘钥 key 进行加密。如：
    # encrypt 'clear text'
    # 或
    # encrypt 'clear text', key: aes256_key
    def encrypt(message, key: nil)
      self.class.encrypt message, key: key
    end

    ##
    # 将密文 encoded 用秘钥 key 进行解密。如：
    # decrypt encoded, key: aes256_key
    def decrypt(encoded, key: nil)
      self.class.decrypt encoded, key: key
    end

    def aes_256_padding
      self.class.aes_256_padding
    end

    ##
    # 将明文 message 用秘钥 key 进行加密，并转换成16进制表达。如：
    # hex_encrypt 'clear text', key: aes256_key
    def hex_encrypt(message, key: nil)
      self.class.hex_encrypt message, key: key
    end

    ##
    # 将明文 message 用秘钥 key 进行解密，并转换成16进制表达。如：
    # hex_decrypt 'clear text'
    # 或
    # hex_decrypt 'clear text', key: aes256_key
    def hex_decrypt(encoded, key: nil)
      self.class.hex_decrypt encoded, key: key
    end

  end

  module ClassMethods

    def encryption_algorithm
      'AES-256-CBC'
    end

    ##
    # 将明文 message 用秘钥 key 进行加密。如：
    # encrypt 'clear text'
    # 或
    # encrypt 'clear text', key: aes256_key
    def encrypt(message, key: nil)

      raise ArgumentError.new('The message argument is required.') if message.blank?
      raise ArgumentError.new('The key argument is required.')     if key.blank?

      cipher = OpenSSL::Cipher::AES.new(256, 'CBC')
      cipher.encrypt
      cipher.padding = aes_256_padding
      cipher.key     = key

      cipher.update(message)+cipher.final

    end

    ##
    # 将密文 encoded 用秘钥 key 进行解密。如：
    # decrypt encoded, key: aes256_key
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

    ##
    # 将明文 message 用秘钥 key 进行加密，并转换成16进制表达。如：
    # self.hex_encrypt 'clear text', key: aes256_key
    def hex_encrypt(message, key: nil)
      Unidom::Common::Numeration.hex encrypt(message, key: key)
    end

    ##
    # 将明文 message 用秘钥 key 进行解密，并转换成16进制表达。如：
    # self.hex_decrypt 'clear text', key: aes256_key
    def hex_decrypt(encoded, key: nil)
      Unidom::Common::Numeration.hex decrypt(Unidom::Common::Numeration.rev_hex(encoded), key: key)
    end

  end

end
