module Unidom::Common::Concerns::SecureColumn

  extend  ActiveSupport::Concern
  include Unidom::Common::Concerns::ExactColumn
  include Unidom::Common::Concerns::Aes256Cryptor

  included do |includer|

    cattr_accessor :secure_columns

    def do_encrypt_secure_column(name)
      name    = name.to_s
      content = { 'nonce' => SecureRandom.hex(8), 'timestamp' => Time.now.to_i }
      secure_columns[name].each do |field| content[field.to_s] = send(field) end
      content = content.sort.to_h.to_json
      aes_key = Digest::SHA512::digest self.class.exact_signature(self.class, name, '')
      encoded = hex_encrypt content, key: aes_key
      json = {
          encoded:   encoded,
          signature: Unidom::Common::Numeration.hex(self.class.exact_signature self.class, name, content),
          encryption_algorithm: self.class.encryption_algorithm
        }
      send "#{name}=", json
    end

    def do_decrypt_secure_column(name)
      name = name.to_sym
      return unless respond_to? name
      json = send(name)
      return if json.blank?||json['encoded'].blank?||json['signature'].blank?||json['encryption_algorithm'].blank?
      return if self.class.encryption_algorithm!=json['encryption_algorithm']
      aes_key = Digest::SHA512::digest self.class.exact_signature(self.class, name, '')
      content = decrypt Unidom::Common::Numeration.rev_hex(json['encoded']), key: aes_key
      actual_signature = self.class.exact_signature(self.class, name, content)
      return if Unidom::Common::Numeration.rev_hex(json['signature'])!=actual_signature
      parsed = JSON.parse content
      parsed.each do |key, value| send "#{key}=", value unless [ 'nonce', 'timestamp' ].include? key end
    end

  end

  module ClassMethods

    ##
    # 配置加密列。如：
    # class YourModel < ApplicationRecord
    #   attr_accessor :identity_card_name, :identity_card_address, :passport_name, :passport_address
    #   include Unidom::Common::Concerns::SecureColumn
    #   secure_column :secure_identity_card, fields: [ :identity_card_name, :identity_card_address ]
    #   secure_column :secure_passport,      fields: [ :passport_name, :passport_address ]
    # end
    #
    # model = YourModel.create! identity_card_name: '张三', identity_card_address: '地址1',
    #   passport_name: '李四', passport_address: '地址2'
    # #identity_card_name 和 #identity_card_address 会被加密后保存到 #secure_identity_card 字段中。
    # #passport_name 和 #passport_address 会被加密后保存到 #secure_passport 字段中。
    # model_2 = YourModel.find model.id
    # model_2.identity_card_name # 张三
    # #secure_identity_card 中存储的加密信息会被自动解密，并存储到 #identity_card_name 和 #identity_card_address 中。
    def secure_column(name, fields: [])

      name                = name.to_s
      self.secure_columns = self.secure_columns||{}
      if secure_columns[name].present?
        raise ArgumentError.new("The #{name} column was defined as a secure column already.")
      else
        secure_columns[name] = fields
      end
      fields.each do |field| attr_accessor field.to_sym if columns_hash[field.to_s].blank? end

      instance_eval do
        before_save do do_encrypt_secure_column name        end
        after_find  do do_decrypt_secure_column name.to_sym end
      end

    end

  end

end
