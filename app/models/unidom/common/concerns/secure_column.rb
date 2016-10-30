module Unidom::Common::Concerns::SecureColumn

  extend  ActiveSupport::Concern
  include Unidom::Common::Concerns::ExactColumn
  include Unidom::Common::Concerns::Aes256Cryptor

  included do |includer|

    cattr_accessor :secure_columns

  end

  module ClassMethods

    def secure_column(name, fields: [])

      name           = name.to_s
      secure_columns = secure_columns||{}
      if secure_columns[name].present?
        raise ArgumentError.new("The #{name} column was defined as a secure column already.")
      else
        secure_columns[name] = fields
      end
      fields.each do |field| attr_accessor field.to_sym if columns_hash[field.to_s].blank? end

      instance_eval do

        before_save do
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

        after_find do
          json = send(name)
          return if json['encoded'].blank?||json['signature'].blank?||json['encryption_algorithm'].blank?
          return if self.class.encryption_algorithm!=json['encryption_algorithm']
          aes_key = Digest::SHA512::digest self.class.exact_signature(self.class, name, '')
          content = decrypt Unidom::Common::Numeration.rev_hex(json['encoded']), key: aes_key
          actual_signature = self.class.exact_signature(self.class, name, content)
          return if Unidom::Common::Numeration.rev_hex(json['signature'])!=actual_signature
          parsed = JSON.parse content
          parsed.each do |key, value| send "#{key}=", value unless [ 'nonce', 'timestamp' ].include? key end
        end

      end

    end

  end

end
